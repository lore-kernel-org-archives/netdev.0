From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCHES 0/5]: DCCP patches for 2.6.25
Date: Mon, 17 Dec 2007 13:00:14 -0200
Message-ID: <1197903619-12301-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.226]:42911 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756573AbXLQPA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 10:00:26 -0500
Received: by nz-out-0506.google.com with SMTP id s18so884965nze.1
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 07:00:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

net/dccp/ccids/ccid3.c |  252 +++++++++++++++++++++++++++++-----------------------------
net/dccp/ccids/ccid3.h |    8 -
net/dccp/dccp.h        |    6 -
3 files changed, 130 insertions(+), 136 deletions(-)
