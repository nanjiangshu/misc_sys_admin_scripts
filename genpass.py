#!/usr/bin/env python3
import os
import secrets

# A starter list of crisp, unambiguous, easy-to-type words (no homophones or tricky spellings)
WORDS = [
    "anchor",
    "apricot",
    "badger",
    "bamboo",
    "beacon",
    "bison",
    "blanket",
    "blizzard",
    "boulder",
    "breeze",
    "cactus",
    "canyon",
    "caravan",
    "cedar",
    "chimney",
    "cipher",
    "clover",
    "cobalt",
    "compass",
    "copper",
    "coral",
    "cricket",
    "crystal",
    "cypress",
    "dolphin",
    "dragon",
    "drift",
    "eclipse",
    "emerald",
    "falcon",
    "feather",
    "flannel",
    "flint",
    "forest",
    "fossil",
    "fountain",
    "galaxy",
    "garnet",
    "glacier",
    "granite",
    "gravel",
    "hammock",
    "harbor",
    "harvest",
    "hazelnut",
    "helmet",
    "horizon",
    "husky",
    "iceberg",
    "indigo",
    "island",
    "jasper",
    "journey",
    "juniper",
    "kayak",
    "kettle",
    "kingdom",
    "lantern",
    "leopard",
    "lighthouse",
    "lizard",
    "magnet",
    "mango",
    "maple",
    "marble",
    "meadow",
    "meteor",
    "monarch",
    "monsoon",
    "mosaic",
    "mustard",
    "nebula",
    "nectar",
    "nickel",
    "nomad",
    "nutmeg",
    "oasis",
    "obsidian",
    "octopus",
    "olive",
    "onyx",
    "orchid",
    "osprey",
    "otter",
    "paddle",
    "panther",
    "papaya",
    "pebble",
    "pelican",
    "pendulum",
    "pepper",
    "phantom",
    "phoenix",
    "pioneer",
    "planet",
    "platinum",
    "pocket",
    "prism",
    "pumpkin",
    "quartz",
    "quiver",
    "raccoon",
    "ravine",
    "redwood",
    "ripple",
    "rocket",
    "saffron",
    "salmon",
    "sandal",
    "sapphire",
    "scarlet",
    "schooner",
    "sequoia",
    "shadow",
    "shelter",
    "silver",
    "skylark",
    "sparrow",
    "sphinx",
    "spruce",
    "squirrel",
    "starlight",
    "summit",
    "sundial",
    "sycamore",
    "tangerine",
    "telescope",
    "thistle",
    "thunder",
    "timber",
    "topaz",
    "tornado",
    "tractor",
    "trident",
    "tundra",
    "turtle",
    "umbrella",
    "unicorn",
    "valley",
    "velvet",
    "volcano",
    "walnut",
    "waterfall",
    "whisper",
    "wildcat",
    "willow",
    "windmill",
    "winter",
    "wolverine",
    "zenith",
    "zephyr",
]


def load_wordlist():
  """Uses the system dictionary (filtered for clean 5-8 letter words) if available,

    giving ~70+ bits of entropy; otherwise falls back to the built-in list.
    """
  dict_paths = ["/usr/share/dict/words", "/usr/share/dict/american-english"]
  for path in dict_paths:
    if os.path.exists(path):
      with open(path, "r", encoding="utf-8", errors="ignore") as f:
        clean_words = [
            w.strip().lower()
            for w in f
            if w.strip().isalpha()
            and w.strip().islower()
            and 5 <= len(w.strip()) <= 8
        ]
      if len(clean_words) >= 4000:
        return clean_words
  return WORDS


def generate_passphrase(num_words=4, capitalize=True, add_number=True):
  wordlist = load_wordlist()
  separator = secrets.choice(["-", ".", "_"])

  chosen = [secrets.choice(wordlist) for _ in range(num_words)]
  if capitalize:
    chosen = [w.capitalize() for w in chosen]

  if add_number:
    # Appends a random 2-digit number (10-99) to satisfy strict site rules
    number = str(secrets.randbelow(90) + 10)
    chosen.append(number)

  return separator.join(chosen)


if __name__ == "__main__":
  print("Generated Passphrases:\n")
  for _ in range(5):
    print(" ", generate_passphrase(num_words=4))
