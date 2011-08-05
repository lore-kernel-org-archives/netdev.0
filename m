From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 0/6] be2net: patch series
Date: Fri, 5 Aug 2011 14:59:19 -0500
Message-ID: <20110805195919.GA13491@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2931 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756089Ab1HEUAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:00:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 6 patches against net-next-2.6
Please apply.

Thanks
-Ajit

[1/6] be2net: set wrb.hdr.domain in be_cmd_link_status_query
[2/6] be2net: add be_cmd_set_port_speed_v1 to set port speed
[3/6] be2net: add be_cmd_get_port_speed to get port speed
[4/6] be2net: add ethtool::set_settings support
[5/6] be2net: Disable RSS for VF interfaces
[6/6] be2net: fix to set ecmd->autoneg correctly
