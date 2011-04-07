From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 0/5] be2net: Patch series
Date: Wed, 6 Apr 2011 23:07:06 -0500
Message-ID: <20110407040706.GA4166@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55043 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750954Ab1DGEHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:07:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 5 patches. Please apply.

Thanks
-Ajit

[1/5] add rxhash support
[2/5] use common method to check for sriov function type
[3/5] fix to get max VFs supported from adapter
[4/5] dynamically allocate adapter->vf_cfg
[5/5] call FLR after setup wol in be_shutdown
