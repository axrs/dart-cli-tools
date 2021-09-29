final ESC = '\u001B[';
final OSC = '\u001B]';
final BEL = '\u0007';
final SEP = ';';

String hyperlink(String text, String link) {
  return [OSC, '8', SEP, SEP, link, BEL, text, OSC, '8', SEP, SEP, BEL]
      .join('');
}
