From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3] Action API fixes
Date: Wed, 05 Jul 2006 00:05:04 +0200
Message-ID: <20060704220504.787776000@postel.suug.ch>
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53957 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932309AbWGDWGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 18:06:40 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Fixes for some rather serious action API bugs. Please apply.

 net/sched/act_api.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

