From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][XFRM][patch 0/1] fix allmodconfig
Date: Wed, 12 Sep 2007 17:27:15 +0200
Message-ID: <20070912152715.747974665@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, Joy Latten <latten@austin.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:45353 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbXILPiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 11:38:51 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8CFcoqG129358
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:38:50 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CFcnnk2080974
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 17:38:49 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CFcnwb014848
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 17:38:49 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes missing export symbols

-- 
