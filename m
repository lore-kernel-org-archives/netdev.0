From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 0/5] be2net: allow register dump only for PFs
Date: Mon, 18 Apr 2011 17:29:41 -0500
Message-ID: <20110418222941.GA9450@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:45942 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752661Ab1DRWaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 18:30:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 5 patches against net-next-2.6
Please apply.

Thanks
-Ajit

[1/5] allow register dump only for PFs
[2/5] Add code to display nic speeds other than 1Gbps/10Gbps
[3/5] fix be_mcc_compl_process to identify eth_get_stat command
[4/5] pass domain id to be_cmd_link_status_query
[5/5] add code to display default value of tx rate for VFs
