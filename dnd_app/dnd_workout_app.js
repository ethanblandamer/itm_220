const classes = {
  Wizard: [
    ["Push-ups", 1], ["Goblet squats", 1], ["Plank", 1],
    ["Jumping jacks", 1], ["Pike push-ups", 2], ["Reverse lunges", 2],
    ["Dead bug", 3], ["Dumbbell shoulder press", 3], ["Bear crawl", 4],
    ["Turkish get-up", 5], ["Handstand hold", 6], ["Renegade row", 8]
  ],

  Rogue: [
    ["Walking lunges", 1], ["Mountain climbers", 1], ["Sit-ups", 1],
    ["Bodyweight squats", 1], ["Lateral shuffles", 2],
    ["Single-leg deadlift", 2], ["Burpees", 3],
    ["Hanging knee raises", 3], ["Box jumps", 4],
    ["Pistol-squat progression", 5], ["Pull-ups", 6], ["Agility shuttle", 8]
  ],

  Paladin: [
    ["Push-ups", 1], ["Squats", 1], ["Farmer’s carry", 1],
    ["Plank", 1], ["Reverse lunges", 2], ["Dumbbell bench press", 2],
    ["Overhead press", 3], ["Romanian deadlift", 3],
    ["Front-rack carry", 4], ["Bulgarian split squat", 5],
    ["Barbell squat", 6], ["Sled push", 8]
  ],

  Bard: [
    ["Dancing steps or step-ups", 1], ["Bodyweight squats", 1],
    ["Push-ups", 1], ["Bicycle crunches", 1], ["Jumping rope", 2],
    ["Alternating lunges", 2], ["Bear crawl", 3],
    ["Kettlebell swings", 3], ["Squat-to-press", 4],
    ["Skater jumps", 5], ["Push-up to side plank", 6],
    ["Burpee broad jump", 8]
  ],

  Barbarian: [
    ["Air squats", 1], ["Push-ups", 1], ["Mountain climbers", 1],
    ["Plank", 1], ["Kettlebell deadlift", 2], ["Walking lunges", 2],
    ["Dumbbell clean", 3], ["Kettlebell swings", 3],
    ["Tire flips or sandbag lifts", 4], ["Front squat", 5],
    ["Deadlift", 6], ["Heavy sled push", 8]
  ],

  Fighter: [
    ["Push-ups", 1], ["Squats", 1], ["Rows", 1], ["Plank", 1],
    ["Dumbbell bench press", 2], ["Split squats", 2],
    ["Shoulder press", 3], ["Romanian deadlift", 3],
    ["Pull-ups", 4], ["Barbell bench press", 5],
    ["Barbell squat", 6], ["Deadlift", 8]
  ],

  Monk: [
    ["Push-ups", 1], ["Lunges", 1], ["Plank", 1], ["Hollow hold", 1],
    ["Diamond push-ups", 2], ["Single-leg balance", 2],
    ["Jump squats", 3], ["Crawling pattern", 3],
    ["Handstand progression", 4], ["L-sit progression", 5],
    ["Pistol squat", 6], ["Muscle-up progression", 8]
  ],

  Cleric: [
    ["Incline push-ups", 1], ["Sit-to-stand squats", 1],
    ["Farmer’s carry", 1], ["Bird dog", 1], ["Step-ups", 2],
    ["Kneeling shoulder press", 2], ["Glute bridge", 3],
    ["Dumbbell row", 3], ["Turkish get-up", 4],
    ["Suitcase carry", 5], ["Overhead carry", 6], ["Windmill", 8]
  ],

  Druid: [
    ["Bodyweight squats", 1], ["Bear crawl", 1], ["Plank", 1],
    ["Glute bridge", 1], ["Reverse lunges", 2], ["Inchworms", 2],
    ["Crab walk", 3], ["Single-leg deadlift", 3],
    ["Kettlebell swing", 4], ["Cossack squat", 5],
    ["Turkish get-up", 6], ["Rope climb progression", 8]
  ],

  Ranger: [
    ["Walking lunges", 1], ["Push-ups", 1], ["Rows", 1], ["Plank", 1],
    ["Step-ups", 2], ["Farmer’s carry", 2], ["Jumping rope", 3],
    ["Pull-ups", 3], ["Kettlebell swings", 4],
    ["Single-leg Romanian deadlift", 5], ["Box jumps", 6],
    ["Loaded hike", 8]
  ],

  Sorcerer: [
    ["Jumping jacks", 1], ["Bodyweight squats", 1],
    ["Incline push-ups", 1], ["Dead bug", 1], ["Squat jumps", 2],
    ["Pike push-ups", 2], ["Mountain climbers", 3],
    ["Dumbbell thrusters", 3], ["Burpees", 4],
    ["Handstand progression", 5], ["Turkish get-up", 6],
    ["Devil’s press", 8]
  ],

  Warlock: [
    ["Push-ups", 1], ["Reverse lunges", 1], ["Plank", 1],
    ["Glute bridge", 1], ["Close-grip push-ups", 2],
    ["Single-arm row", 2], ["Bear crawl", 3],
    ["Kettlebell deadlift", 3], ["Renegade row", 4],
    ["Turkish get-up", 5], ["Pull-ups", 6], ["Heavy carries", 8]
  ]
};

const $ = id => document.getElementById(id);

const character = {
  name: "",
  className: "Wizard",
  level: 1,
  xp: 0
};

Object.keys(classes).forEach(className => {
  $("classSelect").add(new Option(className, className));
});

const savedCharacter = JSON.parse(
  localStorage.getItem("dndWorkoutCharacter") || "null"
);

if (savedCharacter) {
  Object.assign(character, savedCharacter);
}

$("characterName").value = character.name;
$("classSelect").value = character.className;
$("levelInput").value = character.level;
$("xpInput").value = character.xp;

updateSummary();
updateGuide();

function saveCharacter() {
  character.name =
    $("characterName").value.trim() || "Unnamed Hero";

  character.className = $("classSelect").value;

  character.level = Math.min(
    10,
    Math.max(1, Number($("levelInput").value) || 1)
  );

  character.xp = Math.max(
    0,
    Number($("xpInput").value) || 0
  );

  $("levelInput").value = character.level;
  $("xpInput").value = character.xp;

  localStorage.setItem(
    "dndWorkoutCharacter",
    JSON.stringify(character)
  );

  updateSummary();
  updateGuide();

  showMessage(
    "Character saved. The physical dice guide has been updated."
  );
}

function updateSummary() {
  $("summaryName").textContent =
    character.name || "—";

  $("summaryClass").textContent =
    character.className;

  $("summaryLevel").textContent =
    character.level;

  $("summaryXp").textContent =
    character.xp;
}

function updateGuide() {
  const exercises = classes[character.className];

  const unlockedCount = exercises.filter(
    exercise => exercise[1] <= character.level
  ).length;

  $("encounterText").textContent =
    `${character.className} • Level ${character.level} • ` +
    `${unlockedCount} of ${exercises.length} exercises unlocked`;

  $("exerciseTableBody").innerHTML =
    exercises
      .map((exercise, index) => {
        const exerciseName = exercise[0];
        const unlockLevel = exercise[1];
        const unlocked = unlockLevel <= character.level;

        return `
          <tr>
            <td>${index + 1}</td>
            <td>${exerciseName}</td>
            <td>${unlockLevel}</td>
            <td>${unlocked ? "Unlocked" : "Locked"}</td>
          </tr>
        `;
      })
      .join("");
}

function showMessage(text, isError = false) {
  const message = $("message");

  message.textContent = text;
  message.classList.toggle("error", isError);
  message.classList.add("show");
}

$("saveBtn").addEventListener("click", saveCharacter);