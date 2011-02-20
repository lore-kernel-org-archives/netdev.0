From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 0/6] be2net: patch series
Date: Sun, 20 Feb 2011 15:42:42 -0600
Message-ID: <20110220214242.GA13723@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11634 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755110Ab1BTVnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:43:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch series for the be2net driver.

[1/6] be2net: add new counters to display via ethtool stats
[2/6] be2net: fixes in ethtool selftest
[3/6] be2net: variable name change
[4/6] be2net: fix to ignore transparent vlan ids wrongly indicated by NIC
[5/6] be2net: add code to display temperature of ASIC
[6/6] be2net: use hba_port_num instead of port_num

Please Apply.

Thanks
-Ajit
