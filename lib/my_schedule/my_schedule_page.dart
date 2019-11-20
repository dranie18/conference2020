import 'package:conferenceapp/agenda/bloc/bloc.dart';
import 'package:conferenceapp/agenda/widgets/populated_agenda_table.dart';
import 'package:conferenceapp/model/talk.dart';
import 'package:conferenceapp/profile/favorites_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MySchedulePage extends StatefulWidget {
  @override
  _MySchedulePageState createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  PageController pageController;
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    pageController.addListener(() {
      if (pageController.page.round() != currentIndex.value) {
        currentIndex.value = pageController.page.round();
      }
    });
    currentIndex.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesRepository =
        RepositoryProvider.of<FavoritesRepository>(context);

    return BlocBuilder(
      bloc: BlocProvider.of<AgendaBloc>(context),
      builder: (context, AgendaState state) {
        return StreamBuilder<List<Talk>>(
          stream: favoritesRepository.favoriteTalks,
          builder: (context, snapshot) {
            if (state is PopulatedAgendaState &&
                snapshot.hasData &&
                snapshot.data.length > 0) {
              final talksMap = getTalksPerDay(snapshot, state);
              return Column(
                children: <Widget>[
                  PopulatedAgendaTable(
                    talksMap,
                    state.rooms,
                    pageController,
                    currentIndex,
                  ),
                ],
              );
            }
            return MyScheduleEmptyState();
          },
        );
      },
    );
  }

  getTalksPerDay(
      AsyncSnapshot<List<Talk>> snapshot, PopulatedAgendaState state) {
    final talks = {
      0: snapshot.data
          .where((f) => sameDay(f.dateTime, state.talks[0].first.dateTime))
          .toList(),
      1: snapshot.data
          .where((f) => sameDay(f.dateTime, state.talks[1].first.dateTime))
          .toList(),
    };
    return talks;
  }

  bool sameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class MyScheduleEmptyState extends StatelessWidget {
  const MyScheduleEmptyState({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/no_data.png',
            height: 200,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Here you will see your observed talks'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Add some by tapping ❤️'),
          ),
        ],
      ),
    );
  }
}
