From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 0/3] fixes for the core network namespace
Date: Wed, 12 Sep 2007 14:38:11 +0200
Message-ID: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:1629 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966516AbXILMp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:45:58 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8CCjvOB475098
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:45:57 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CCjuO92072732
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:45:56 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CCjuHY016901
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:45:56 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches fixes some compilation errors and boot problems
related to the network namespace patchset.

They apply to net-2.6.24
-- 
