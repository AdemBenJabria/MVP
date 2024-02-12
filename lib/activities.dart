import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity.dart';
import 'activityDetailPage.dart';
import 'activitySuggestionsService.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final List<String> _categories = [
    'Tous',
    'Sport',
    'Culture',
    'Nature',
    'Gastronomie',
    'Ludique'
  ];

  List<String> _suggestedActivityTitles = [];

  @override
  void initState() {
    super.initState();
    _updateRecommendedActivities();
  }

  Future<void> _updateRecommendedActivities() async {
    ActivitySuggestionsService suggestionsService =
        ActivitySuggestionsService();
    List<String> suggestedActivityTitles =
        await suggestionsService.getSuggestedActivityTitles();
    setState(() {
      _suggestedActivityTitles = suggestedActivityTitles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activités'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _categories
                .map((String category) => Tab(text: category))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: _categories
              .map((category) => _buildActivityListForCategory(category))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActivityListForCategory(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: (category == 'Tous')
          ? FirebaseFirestore.instance.collection('activites').snapshots()
          : FirebaseFirestore.instance
              .collection('activites')
              .where('categorie', isEqualTo: category)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        List<Activity> activities = snapshot.data!.docs
            .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            Activity activity = activities[index];
            bool isRecommended =
                _suggestedActivityTitles.contains(activity.title);

            return ListTile(
              leading: Image.network(activity.imageUrl),
              title: Text(activity.title),
              subtitle: Text('${activity.lieu} - ${activity.prix}€'),
              trailing:
                  isRecommended ? Icon(Icons.star, color: Colors.yellow) : null,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ActivityDetailPage(activity: activity)));
              },
            );
          },
        );
      },
    );
  }
}
