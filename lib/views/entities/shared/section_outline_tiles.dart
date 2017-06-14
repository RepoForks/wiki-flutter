import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/entity.dart';

// import '../../shared/html_wrapper.dart';
import '../show.dart';
import '../sections/show.dart';

// TODO may be refined after models created. maybe move code to models.
List<Widget> sectionOutlineTiles(Entity entity, { rootSectionId: 0, selectedSectionId: null, showMainSection: false }) {
  List<Section> sections = [];
  if ( rootSectionId == 0 ) {
    sections = entity.sections;
  } else {
    final int rootSectionTocLevel = entity.sections[rootSectionId].tocLevel;
    for (var cursorSectionId = rootSectionId + 1 ; cursorSectionId < entity.sections.length ; cursorSectionId++ ) {
      final Section cursorSection = entity.sections[cursorSectionId];
      if ( cursorSection.tocLevel <= rootSectionTocLevel ) { break; }
      sections.add(cursorSection);
    }
    // add current section as a header in the outline
    if (sections.length > 0) { sections.insert(0, entity.sections[rootSectionId]); }
  }

  final iterableSections = showMainSection ? sections : sections.skipWhile( (Section section) => section.id == 0 );
  return iterableSections.map((Section section){
    return new _SectionListTile(entity, section, (section.id == selectedSectionId));
  }).toList();
}

class _SectionListTile extends StatelessWidget {
  final Entity entity;
  final Section section;
  final bool selected;

  _SectionListTile(this.entity, this.section, this.selected, { Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Icon> prefixIcons =
      ( section.id == 0 ) ?
      ( [ const Icon(Icons.subject) ] ) :
      ( new List<Icon>.filled(section.tocLevel, const Icon(Icons.remove)) );
    if (selected) { prefixIcons[0] = const Icon(Icons.label_outline);}

    final Widget titleContent =
      ( section.id == 0 ) ?
      ( new Expanded( child: new Text('Main Section') ) ): // TODO use entity title?
      ( new Expanded( child: new Text( section.title ) ) );
    final List<Widget> titleRowChildren = []
      ..addAll(prefixIcons)
      ..add(titleContent);

    final ListTile sectionTile = new ListTile(
      title: new Row( children: titleRowChildren ),
      // leading: const Text(''),
      dense: true,
      selected: selected,
      onTap: (){
        // TODO HIGH PRIORITY, KINDA COMPLEX
        // if inside the drawer, should replace current route to close the drawer, I guess
        // if the target section is the same as the current section, should just close the drawer, I guess
        Navigator.of(context).push(
          new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return ( section.id == 0 ) ? ( new EntitiesShow( entity: entity ) ) : ( new EntitiesSectionsShow(entity: entity, section: section) );
            }
          )
        );
      },
    );

    return new _AnimatedSectionTile(sectionTile: sectionTile);
  }
}

class _AnimatedSectionTile extends StatefulWidget {
  final ListTile sectionTile;

  const _AnimatedSectionTile({ Key key, this.sectionTile }) : super(key: key);

  @override
  _AnimatedSectionTileState createState() => new _AnimatedSectionTileState();
}

class _AnimatedSectionTileState extends State<_AnimatedSectionTile> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Timer.run((){
      setState((){
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(child: widget.sectionTile, opacity: opacity, duration: const Duration(milliseconds: 300),);
  }
}
