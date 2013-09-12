From: Vladimir Murzin <murzin.v@gmail.com>
Subject: small PAGE_SIZE related fixes for wl{12,18}xx drivers
Date: Thu, 12 Sep 2013 17:32:20 +0200
Message-ID: <1378999943-1968-1-git-send-email-murzin.v@gmail.com>
Cc: coelho@ti.com, linville@tuxdriver.com
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:42114 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab3ILPdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:33:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This small series is considering PAGE_SIZE usage into the wl drivers. I have
no real HW to test it tightly, probably these drivers will never run on arches
with PAGE_SIZE different to 4K. Nevertheless, I hope this mini-series (or some
part of it) will be useful for you.

Thanks.
Vladimir
