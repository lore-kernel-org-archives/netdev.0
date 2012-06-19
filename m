From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 07/19] team: comments: s/net\/drivers\/team/drivers\/net\/team/
Date: Tue, 19 Jun 2012 17:54:09 +0200
Message-ID: <1340121261-2966-8-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:36 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c                   |    2 +-
 drivers/net/team/team_mode_activebackup.c |    2 +-
 drivers/net/team/team_mode_roundrobin.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 32cb290..7ec53f8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1,5 +1,5 @@
 /*
- * net/drivers/team/team.c - Network team device driver
+ * drivers/net/team/team.c - Network team device driver
  * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index acd925f..bcc7d6d 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -1,5 +1,5 @@
 /*
- * net/drivers/team/team_mode_activebackup.c - Active-backup mode for team
+ * drivers/net/team/team_mode_activebackup.c - Active-backup mode for team
  * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index daafca2..52dd0ec 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -1,5 +1,5 @@
 /*
- * net/drivers/team/team_mode_roundrobin.c - Round-robin mode for team
+ * drivers/net/team/team_mode_roundrobin.c - Round-robin mode for team
  * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
  *
  * This program is free software; you can redistribute it and/or modify
-- 
1.7.10.2
