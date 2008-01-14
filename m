From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/8 2.6.25] a set of small code cleanups
Date: Mon, 14 Jan 2008 17:59:23 +0300
Message-ID: <478B78CB.4030404@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53747 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750966AbYANPdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 10:33:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains a set of small improvements found in IPv4 code during
preparations to support ARP in the network namespace. These fixes are
mostly independent except 2 last ones.

Signed-off-by: Denis V. Lunev <den@openvz.org>
