# Trouble In Armaville

**An Arma 3 adaptation of the iconic Trouble In Terrorist Town game mode.**  
Built for tactical deception, social deduction, and explosive chaos — in the uniquely sandboxy Arma 3 engine.

<p align="center">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/ui/TroubleInArmaville.jpg?raw=true" alt="Trouble In Armaville Logo" width="512">
</p>

---

## 🎮 About

Trouble In Armaville (TTT) is a re-imagining of the GMod game mode **Trouble In Terrorist Town**, fully implemented in **Arma 3**.

Built for seamless multiplayer, TTT in Armaville supports:
- Randomised traitor/detective/innocent role assignment
- Investigative gameplay with hidden objectives
- Dynamic airdrops, loot spawns, buy menus and arena generation
- Clean UI and round timers
- Jester chaos

This version (2.5.0 RC) includes a major refactor for stability, scalability, and maintainability.

---

## 🧰 Features

- 🔀 **Dynamic Role System** – configurable traitor %, detective, jester inclusion  
- 🌆 **Arena Generator** – auto-finds towns and builds circular, scalable play zones  
- 🎯 **Custom Buy Menus** – traitors and detectives get access to powerful tools  
- ☁️ **Dynamic Weather** – fog, rain, time of day, all configurable  
- 🚁 **Airdrops** – periodic random supply drops to spice up gameplay  
- 🎵 **Intro Music** – loading screen music (configurable in `description.ext`)  
- 🧠 **Full parameter integration** – round length, role chance, game modifiers

---

## 📦 Installation

1. Download this repo release.
2. Copy the mission folder into your Arma 3 missions directory
3. Launch in Multiplayer

---

## ⚙️ Configuration

### Editable Parameters (via Lobby Menu):

| Parameter                | Description                                 |
|--------------------------|---------------------------------------------|
| `Traitor % Range`        | Min/Max traitor percentage                  |
| `Detective Enabled`      | Toggle for detective role                   |
| `Jester Enabled`         | Chance and toggle for jester chaos          |
| `Round Length`           | Base + per player + per traitor             |
| `Airdrops Enabled`       | Enables random supply drops                 |
| `Rain / Fog`             | Controls chance and density                 |
| `Developer Mode`         | Disables traitor win for testing            |

You can also adjust default values in `config.sqf`.

---

## 🖼️ Screenshots

*Coming soon*

---

## 🛠️ Dependencies

- Arma 3
- CBA_A3

ACE isn't officially supported but can work if you disable the medical or uncon rule for fair play.

---

## 📄 License

This project is released associated with [Waldo’s Mission Pack](https://github.com/AdamWaldie/WaldosMissionPack) and is released under the MIT License.  
You are free to fork, extend, and contribute.

---

## 🙌 Credits

Developed by [AdamWaldie](https://github.com/AdamWaldie)  
Design inspiration from GMod’s original TTT mode and its community.

---

> “Innocents win... or do they?”  


