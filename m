From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCHES 0/3]: DCCP patches for 2.6.25
Date: Thu, 13 Dec 2007 23:41:59 -0200
Message-ID: <1197596522-14600-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:32486 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758398AbXLNBn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 20:43:57 -0500
Received: by an-out-0708.google.com with SMTP id d31so249125and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 17:43:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 net/dccp/ccid.c        |    8 ++++----
 net/dccp/ccid.h        |   37 ++++++++++++++++++++++++++++++-------
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 net/dccp/output.c      |   30 +++++++++++++++++++++++-------
 5 files changed, 59 insertions(+), 20 deletions(-)
