From: Petr Sabata <contyk@redhat.com>
Subject: [PATCH 0/3] iproute2: various usage and doc fixes
Date: Thu,  6 Oct 2011 14:45:31 +0200
Message-ID: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Cc: Petr Sabata <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758255Ab1JFMrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 08:47:37 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p96ClbS3009910
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 08:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Petr Sabata (3):
  iproute2: ss - fix missing parameters
  iproute2: lnstat - fix typos
  iproute2: arpd - fix usage and manpage options

 man/man8/arpd.8 |    4 ++--
 man/man8/ss.8   |    4 ++--
 misc/arpd.c     |    2 +-
 misc/lnstat.c   |    4 ++--
 misc/ss.c       |    6 ++++--
 5 files changed, 11 insertions(+), 9 deletions(-)

-- 
1.7.6.4
