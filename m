From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/3][NETNS][IPV6] make anycast and ip6_flowlabels per namespace
Date: Wed, 26 Mar 2008 13:28:32 +0100
Message-ID: <20080326122832.564021438@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:30050 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650AbYCZMc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:32:26 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2QCWOM6235614
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 12:32:24 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QCWO6K1810586
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 13:32:24 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QCWNrE028513
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 13:32:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the anycast and ip6_flowlabel per namespace.

-- 
