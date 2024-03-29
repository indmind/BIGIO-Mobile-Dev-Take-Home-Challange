import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/character_model.dart';
import '../../providers/characters/favorite_characters_provider.dart';
import '../../providers/common/dominant_color_provider.dart';
import '../../providers/common/foreground_color_provider.dart';
import 'character_gender.dart';
import 'character_image_placeholder.dart';
import 'character_species.dart';

class CharacterCard extends ConsumerStatefulWidget {
  const CharacterCard({
    super.key,
    required this.character,
    this.imageHeroTag,
    this.onPressed,
    this.withUnfavoriteAnimation = false,
  });

  final CharacterModel character;
  final String? imageHeroTag;
  final VoidCallback? onPressed;
  final bool withUnfavoriteAnimation;

  @override
  ConsumerState<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends ConsumerState<CharacterCard> {
  bool _isUnfavorited = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominantColor =
        ref.watch(dominantColorProvider(widget.character.image)).value ??
            Colors.grey.shade200;

    return AnimatedContainer(
      duration: 300.milliseconds,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: dominantColor.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: widget.withUnfavoriteAnimation && _isUnfavorited
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.fromLTRB(16, 8, 8, 8) + const EdgeInsets.all(16),
      height: widget.withUnfavoriteAnimation && _isUnfavorited ? 0 : 138,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onPressed,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -16,
                left: -16,
                child: widget.imageHeroTag != null
                    ? Hero(
                        tag: widget.imageHeroTag!,
                        child: _buildImage(),
                      )
                    : _buildImage(),
              ),
              Positioned.fill(
                top: 12,
                left: 128,
                right: 16,
                bottom: 8,
                child: widget.withUnfavoriteAnimation
                    ? SingleChildScrollView(
                        child: _buildDetail(theme, dominantColor),
                      )
                    : _buildDetail(theme, dominantColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildDetail(ThemeData theme, Color dominantColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.character.name ?? '',
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CharacterSpecies(
              character: widget.character,
              isExpanded: true,
            ),
            const SizedBox(height: 2),
            CharacterGender(character: widget.character),
          ],
        ),
        _buildFavoriteButton(dominantColor),
      ],
    );
  }

  Widget _buildFavoriteButton(Color dominantColor) {
    return Consumer(
      builder: (context, ref, child) {
        final isFavorited = ref.watch(
          isCharacterFavoritedProvider(widget.character),
        );
        final forground = ref.watch(foregroundColorProvider(dominantColor));

        return FilledButton(
            onPressed: () async {
              if (widget.withUnfavoriteAnimation && isFavorited) {
                setState(() {
                  _isUnfavorited = true;
                });

                await Future.delayed(300.milliseconds);
              }
              ref.read(favoriteCharactersProvider.notifier).toggleFavorite(
                    widget.character,
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: isFavorited ? dominantColor : Colors.black45,
              foregroundColor: isFavorited ? forground : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFavorited)
                  Icon(
                    Icons.favorite,
                    size: 12,
                    color: Colors.red.shade400,
                  )
                else
                  const Icon(
                    Icons.favorite_border,
                    size: 12,
                    color: Colors.white,
                  ),
                const SizedBox(width: 8),
                if (isFavorited)
                  const Text('u fav this!')
                else
                  const Text('fav this!'),
              ],
            ));
      },
    );
  }

  Widget _buildImage() {
    return AnimatedOpacity(
      duration: 300.milliseconds,
      curve: Curves.easeInOut,
      opacity: widget.withUnfavoriteAnimation && _isUnfavorited ? 0 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.character.image == null || widget.character.image!.isEmpty
            ? const CharacterImagePlaceholder()
            : CachedNetworkImage(
                imageUrl: widget.character.image ?? '',
                placeholder: (context, url) =>
                    const CharacterImagePlaceholder(),
                width: 128,
                height: 128,
              ),
      ),
    );
  }
}
