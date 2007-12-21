From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 0/2][NETNS] prepare the neigh subsys to handle network namespaces v2
Date: Fri, 21 Dec 2007 14:59:22 +0100
Message-ID: <20071221135922.726347008@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:56165 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbXLUOwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:52:00 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBLEpuLj150206
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:51:56 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBLEpuIh4943982
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:51:56 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBLEpdKF023550
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:51:40 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are coming from Eric Biederman patchset
to make the neighbouring aware of the namespaces.

The description in the patch headers is big enough to add
more comments here  :) 

Changelog:
 v2 :
	fixed bad coding style
 v1 : 
	initial post

-- 
