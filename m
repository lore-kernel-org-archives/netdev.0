From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 0/2] Fixes to MPC5200 FEC driver
Date: Thu, 01 Nov 2007 08:22:24 -0600
Message-ID: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jgarzik@pobox.com, domen.puncer@telargo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:32646 "EHLO
	pd2mo1so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbXKAOXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 10:23:24 -0400
Received: from pd3mr1so.prod.shaw.ca
 (pd3mr1so-qfe3.prod.shaw.ca [10.0.141.177]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JQT008XYZXEXVB0@l-daemon> for netdev@vger.kernel.org; Thu,
 01 Nov 2007 08:22:26 -0600 (MDT)
Received: from pn2ml2so.prod.shaw.ca ([10.0.121.146])
 by pd3mr1so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JQT00FJZZXD7B00@pd3mr1so.prod.shaw.ca> for
 netdev@vger.kernel.org; Thu, 01 Nov 2007 08:22:25 -0600 (MDT)
Received: from trillian.cg.shawcable.net ([68.147.67.118])
 by l-daemon (Sun Java System Messaging Server 6.2-7.05 (built Sep  5 2006))
 with ESMTP id <0JQT00FH8ZXCHB20@l-daemon> for netdev@vger.kernel.org; Thu,
 01 Nov 2007 08:22:25 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oops, send this series yesterday but forgot to include jgarzik, domen
and netdev to the 'to:' list.

These are fixes which should go in for .24

Cheers,
g.

--
Grant Likely, B.Sc. P.Eng.
Secret Lab Technologies Ltd.
