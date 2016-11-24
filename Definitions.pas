unit Definitions;

interface

uses
  System.SysUtils;

type
  TEdgeTests = (TooManyDefines = 1, MaximumNesting, NoConditionals, None );
  TConditionals = (noConditional, endif, ifdef, els, ifndef, define, undefine);
  TSwitchCommand = (baredefine = 1, defining, undefining,
                    quickhelp, fullhelp, pagedhelp, examples, createinfile,
                    quietrewrite, forceddirectories, report, verbose,
                    comment, noaction);
  TCommentMarkers = (hash = 1, cSingleLine, cMultiline, html,
                  jinja, django, batch, doubleQuote, userDefined);

const
  TAB = Chr(9);
  TAB2 = TAB + TAB;
  TAB3 = TAB2 + TAB;
  TAB4 = TAB3 + TAB;

  MAX_NESTING = 20;

  SWITCH_DELIMITER_COUNT = 3;
  SWITCH_DELIMITERS  : array[1..SWITCH_DELIMITER_COUNT] of string = ('--', '/', '-');

  FIRST_COMMENT_MARKER = Low(TCommentMarkers);
  LAST_COMMENT_MARKER = High(TCommentMarkers);

  PREDEFINED_COMMENT_MARKERS : array[TCommentMarkers] of string = ('#', '//', '/*', '<!--', '{#', '{% comment ', 'rem ', '"', '<user>');
  COMMENT_MARKER_DESCRIPTION : array[TCommentMarkers] of string =
    (TAB + 'PHP',
    TAB + 'Javascript, PHP',
    TAB + 'CSS',
    TAB + 'HTML, XML',
    TAB + 'Phalcon Volt, Jinja',
    'Django - trailing space required',
    TAB + 'Batch files - trailing space required',
    TAB + 'Not sure, but defined because it''s hard to define on the command line',
    TAB + 'Whatever you want');

  FIRST_CONDITIONAL = endif; // NoConditional is not checked for
  LAST_CONDITIONAL = High(TConditionals);

  CONDITIONALS : array[TConditionals] of string = ('', 'endif', 'ifdef ', 'else', 'ifndef ', 'def ', 'undef ');
  EDGE_TEST : array[TConditionals] of TEdgeTests = (None, NoConditionals, MaximumNesting, NoConditionals, MaximumNesting,
     None, None);
  PARAMETER_REQUIRED : array[TConditionals] of boolean = (False, False, True, False, True, True, True);

implementation

end.
