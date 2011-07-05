From: Max Matveev <makc@redhat.com>
Subject: [PATCHv2 0/2] Minor documentation updates for ip-related tunables
Date: Tue,  5 Jul 2011 11:57:18 +1000 (EST)
Message-ID: <20110705015718.32777815DBB1@regina.usersys.redhat.com>
Cc: netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29341 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab1GEB5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 21:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Confusion about the way SCTP uses its rmem and wmem tunables
prompted a documentation revision.

v2: incorporate suggestions by Shan Wei and Neil Horman.

Max Matveev (2):
  Update description of net.sctp.sctp_rmem and net.sctp.sctp_wmem tunables
  Update documented default values for various TCP/UDP tunables

 Documentation/networking/ip-sysctl.txt |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

-- 
1.7.3.3

