From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/1]: ip: iplink_vlan: add 802.1ad support
Date: Fri, 19 Apr 2013 14:09:50 +0200
Message-ID: <1366373391-10534-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46161 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968237Ab3DSMJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch adds support to ip_vlan for configuring VLAN 802.1ad
support. It depends on the patch series for the VLAN driver which I just
sent to Dave/netdev.
