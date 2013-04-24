From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 0/3] be2net: patch series
Date: Wed, 24 Apr 2013 16:51:52 -0500
Message-ID: <20130424215152.GA5778@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:7538 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757864Ab3DXVv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 17:51:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[1/3] be2net: Remove an incorrect pvid check in Tx
[2/3] be2net: fix a Tx stall bug caused by a specific ipv6 packet
[3/3] be2net: Fix PVID tag offload for packets with inline VLAN tag.

Pls apply.

Thanks
-Ajit
