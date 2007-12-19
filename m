From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/2][NETNS] prepare the neigh subsys to handle network namespaces
Date: Wed, 19 Dec 2007 15:55:44 +0100
Message-ID: <20071219145544.184198087@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:63788 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334AbXLSPDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 10:03:46 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBJF3jNL217226
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 15:03:45 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBJF3iYM2580664
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 16:03:44 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBJF3hrq024597
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 16:03:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are coming from Eric Biederman patchset
to make the neighbouring to be aware of the namespaces.

The description in the patch headers is big enough to add
more comments here :)

-- 
