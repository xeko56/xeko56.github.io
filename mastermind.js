$(document).ready(function() {
    var rolls = 0;
    var filledAll = false;
    const colorList = ["red", "blue", "yellow", "green"];
    var farbe1 = colorList[Math.floor(Math.random() * colorList.length)];
    var farbe2 = colorList[Math.floor(Math.random() * colorList.length)];
    var farbe3 = colorList[Math.floor(Math.random() * colorList.length)];
    var farbe4 = colorList[Math.floor(Math.random() * colorList.length)];
    var solution = [farbe1, farbe2, farbe3, farbe4];

    $('#generateButton').on('click', function() {
        farbe1 = colorList[Math.floor(Math.random() * colorList.length)];
        farbe2 = colorList[Math.floor(Math.random() * colorList.length)];
        farbe3 = colorList[Math.floor(Math.random() * colorList.length)];
        farbe4 = colorList[Math.floor(Math.random() * colorList.length)];
        solution = [farbe1, farbe2, farbe3, farbe4];
        console.log("After click: " + solution);
    });

    $('#playerName').on('input', function() {
        if ($('#playerName').val().length === 0) {
            $('#colorTable').hide();
        } else {
            $('#colorTable').show();
        }
    });

    $('#colorTable').on('change', function() {
        if ($('#farbe1').val() != "white" && $('#farbe2').val() != "white" && $('#farbe3').val() != "white" &&
            $('#farbe4').val() != "white") {
            filledAll = true;
            rolls += 1;
            console.log("Rolls: " + rolls);
            updateTable();
        }
    });


    function isMatch() {
        if ($('#farbe1').val() === farbe1 && $('#farbe2').val() === farbe2 && $('#farbe3').val() === farbe3 &&
            $('#farbe4').val() === farbe4) {
            return true;
        } else {
            return false;
        }
    }

    function clearAll() {
        $('.color').each(function() {
            $(this).val("white").change();
        });
    }

    function updateTable() {
        if (filledAll) {
            var selected = [$('#farbe1').val(), $('#farbe2').val(), $('#farbe3').val(), $('#farbe4').val()];

            if (JSON.stringify(solution) === JSON.stringify(selected)) {
                $('#colorTable tr:last').before('<tr><td class="f ' + solution[0] + '"></td>+\n\
                <td class="f ' + solution[1] + '"></td>+\n\
                <td class="f ' + solution[2] + '"></td>+\n\
                <td class="f ' + solution[3] + '"></td>+\n\
                <td>Richtige Farben/Positionen: 4</td>+\n\
                </tr>');

                var score = 1000 - (rolls - 1) * 100;

                $('#colorTable').after('<div class="text-success font-weight-bold">RICHTIG!</div>\n\
                                        <div class="scoreDiv"><label for="score">Score:</label><input type="text" name="score" id="score" value="' + score + '"></div>\n\
                                        ');
                $('.color').each(function() {
                    $(this).prop('disabled', true);
                })

                clearAll();

                $.ajax({
                    url: "http://localhost:3000/save-score",
                    type: "POST",
                    data: { playerName: $('#playerName').val(), score: $('#score').val() },
                    dataType: 'json',
                    success: function(result) {
                        $('.scoreDiv').append('<div><h3>Der Score wurde erfolgreich gespeichert!</h3></div>');
                    }
                });

            } else {
                var count = 0;
                console.log(solution);
                console.log(selected);
                for (var i = 0; i < solution.length; i++) {
                    if (solution[i] == selected[i]) {
                        console.log(count);
                        count++;
                    }
                }
                $('#colorTable tr:last').before('<tr><td class="f ' + selected[0] + '"></td>+\n\
                <td class="f ' + selected[1] + '"></td>+\n\
                <td class="f ' + selected[2] + '"></td>+\n\
                <td class="f ' + selected[3] + '"></td>+\n\
                <td>Richtige Farben/Positionen: ' + count + '</td>+\n\
                </tr>');

                clearAll();

                if (rolls >= 11) {
                    $('.color').each(function() {
                        $(this).prop('disabled', true);
                    })

                    $('#colorTable').after('<div class="text-danger font-weight-bold">YOU LOSE!</div>');
                }
            }

        }
    }


    $('.resetButton').on('click', function() {
        location.reload();
    });

    $('.highscoreboard').on('click', function() {
        console.log("click");
        $.ajax({
            url: "http://localhost:3000/highscoreboard",
            type: "POST",
            data: "",
            dataType: 'json',
            success: function(result) {
                console.log("Success");
            }
        });

    });

});