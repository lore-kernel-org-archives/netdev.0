From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 0/7] be2net: Bug fixes
Date: Fri, 27 Sep 2013 15:16:54 -0500
Message-ID: <20130927201654.GA4494@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29040 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904Ab3I0UQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:16:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 7 patches against net tree.
Please apply.

Thanks
-Ajit

[1/7] be2net: Fix to prevent Tx stall on SH-R when packet size < 32
[2/7] be2net: Fix the size of be_nic_res_desc structure
[3/7] be2net: Fix VLAN promiscuous mode programming
[4/7] be2net: Fix number of VLANs supported in UMC mode for BE3-R.
[5/7] be2net: Fix to allow VLAN configuration on VF interfaces.
[6/7] be2net: Fix to configure VLAN priority for a VF interface.
[7/7] be2net: Fix to display the VLAN priority for a VF
