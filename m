From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 00/12][NETNS][IPV6] Finish the routing per namespace
Date: Tue, 04 Mar 2008 22:03:26 +0100
Message-ID: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:4942 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbYCDVMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:12:35 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m24LCYlu219360
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LCX4f2146528
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LCX7f029463
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:33 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This second round of patches makes the routing per namespace to be 
complete and to have the routing engine to support multiple network
namespace.

-- 
