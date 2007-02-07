From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 0/4] spidernet: support for Celleb
Date: Wed, 07 Feb 2007 17:49:50 +0900 (JST)
Message-ID: <200702070849.l178nvGC005341@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jim@jklewis.com
To: jgarzik@pobox.com, jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:40180 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030202AbXBGIu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:50:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a revised spidernet patch set based on
netdev-2.6.git#upstream.

This patch set is merged Jens-san's spidernet patch and works on
Toshiba Cell reference set (aka Celleb). 
It requires Jens-san's phy patch
(http://ozlabs.org/pipermail/linuxppc-dev/2007-February/030987.html).

Ignore our previos patch set, and try this patch set on Cell Blade,
please (sorry for asking a lot).

Best regards,
Kou Ishizaki
