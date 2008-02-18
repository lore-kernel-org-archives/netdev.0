From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/1] s390: claw - More use DIV_ROUND_UP
Date: Mon, 18 Feb 2008 14:41:54 +0100
Message-ID: <20080218134154.893427000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:46842 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368AbYBRNsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 08:48:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Jeff,

this patch is intended for 2.6.25.
It makes use of the DIV_ROUND_UP function as proposed by Julia Lawall.

Regards, Ursula Braun
