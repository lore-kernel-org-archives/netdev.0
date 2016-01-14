From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: [requrest for stable 4.1.y inclution] Fix for CVE-2015-7799
Date: Thu, 14 Jan 2016 20:56:46 +0900
Message-ID: <56978CFE.1010703@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:32468 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcANL4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 06:56:50 -0500
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id E8E87AC0454
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 20:56:46 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is the fix for CVE-2015-7799
Upstream commit 4ab42d78e37a294ac7bc56901d563c642e03c4ae

Stable 3.2.y has included this patch in v3.2.75.
https://cdn.kernel.org/pub/linux/kernel/v3.x/ChangeLog-3.2.75

Please include in this patch to stable 4.1.y.

Best regard,
Yuki Machida
