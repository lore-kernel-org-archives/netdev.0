From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCHES 0/3]: DCCP patches for 2.6.25
Date: Sat,  8 Dec 2007 16:52:10 -0200
Message-ID: <1197139933-11609-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:3633 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbXLHSwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 13:52:23 -0500
Received: by an-out-0708.google.com with SMTP id d31so284712and
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2007 10:52:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/net/dccp/ccids/ccid3.c              |   16 ++++++++--------
 b/net/dccp/ccids/lib/loss_interval.c  |    2 +-
 b/net/dccp/ccids/lib/packet_history.c |   13 ++++++-------
 net/dccp/ccids/ccid3.c                |    4 +---
 net/dccp/ccids/lib/packet_history.c   |    6 ------
 5 files changed, 16 insertions(+), 25 deletions(-)
