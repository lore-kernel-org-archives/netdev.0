From: Roger While <simrw@sim-basis.de>
Subject: [git patches] net driver updates
Date: Wed, 21 Feb 2007 12:46:46 +0100
Message-ID: <6.1.1.1.2.20070221124144.04783fb8@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout06.sul.t-online.com ([194.25.134.19]:49746 "EHLO
	mailout06.sul.t-online.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161210AbXBULrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 06:47:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
>Dan Williams (1):
>       prism54: correct assignment of DOT1XENABLE in WE-19 codepaths

Where did this spring from ?
I see no posting of this patch let alone
an ACK.
The patch is also doing rather more than the description -
It is inserting extra breaks into a switch statement with
no comment as to why.

Roger While


