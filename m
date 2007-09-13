From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 0/1] fix allnoconfig compilation erro
Date: Thu, 13 Sep 2007 08:01:51 +0200
Message-ID: <20070913060151.898030855@mai.toulouse-stg.fr.ibm.com>
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:22603 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbXIMGHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 02:07:51 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8D67nDx202970
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 06:07:49 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8D67nL63047532
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 07:07:49 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8D67hGQ025376
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 07:07:43 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fixes a compilation issue when allnoconfig is used.
 - init_net is unresolved.

-- 
