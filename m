From: Max Matveev <makc@redhat.com>
Subject: [PATCH 0/2] Minor documentation updates for ip-related tunables
Date: Mon, 4 Jul 2011 18:28:40 +1000
Message-ID: <20110704083540.C51AF8156C57@regina.usersys.redhat.com>
Cc: netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927Ab1GDIfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 04:35:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Confusion about the way SCTP uses its rmem and wmem tunables
prompted a documentation revision.

Max Matveev (2):
  Update description of net.sctp.sctp_rmem and net.sctp.sctp_wmem tunables
  Update documented default values for various TCP/UDP tunables

 Documentation/networking/ip-sysctl.txt |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

-- 
1.7.3.3

