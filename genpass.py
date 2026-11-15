#!/usr/bin/env python3
import argparse
import os
import secrets

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


def generate_passphrase(
    wordlist, num_words=4, capitalize=True, add_number=True
):
  separator = secrets.choice(["-", ".", "_"])
  chosen = [secrets.choice(wordlist) for _ in range(num_words)]

  if capitalize:
    chosen = [w.capitalize() for w in chosen]

  if add_number:
    chosen.append(str(secrets.randbelow(90) + 10))

  return separator.join(chosen)


if __name__ == "__main__":
  parser = argparse.ArgumentParser(
      description="Generate an easy-to-type passphrase."
  )
  parser.add_argument(
      "-w", "--words", type=int, default=4, help="Number of words (default: 4)"
  )
  parser.add_argument(
      "-n",
      "--count",
      type=int,
      default=1,
      help="Number of passphrases to generate (default: 1)",
  )
  args = parser.parse_args()

  wordlist = load_wordlist()
  for _ in range(args.count):
    print(generate_passphrase(wordlist, num_words=args.words))
