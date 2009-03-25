From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 0/10] Neterion: New driver: vxge: Resubmission
Date: 25 Mar 2009 00:12:21 -0800
Message-ID: <1237968736.1655.257.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:43783 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755784AbZCYH1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:27:37 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id D3CBB20DE6F1
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 03:27:31 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id M2ZMf5a4BaFH6VRj for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 03:27:31 -0400 (EDT)
Received: from [10.16.17.101] ([10.16.17.101])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n2P7RUAV029519
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 03:27:31 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of 10 patches are a resubmission of Neterion's new driver,
"vxge", for our latest PCIe based X3100 10GbE Server/Storage Adapter. 

Changes from the last submission include fixes from comments from Ben 
Hutchings, Andi Kleen, Bill Fink and David Miller. The details of the fixes are
in the individual patches.

Regards,

Ram



