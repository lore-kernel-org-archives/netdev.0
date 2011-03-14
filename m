From: Domenico Andreoli <cavokz@gmail.com>
Subject: [PATCH v2 0/2] CS89x0: add QQ2440 networking support
Date: Mon, 14 Mar 2011 13:46:27 +0000
Message-ID: <20110314134627.GA11935@dandreoli.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60251 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545Ab1CNMoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 08:44:24 -0400
Received: by eyx24 with SMTP id 24so1596028eyx.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 05:44:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  this patchset cleans some bit left from the CS89x0_NONISA_IRQ
transition and then enables the support of CS89x0 on QQ2440.

Thanks,
Domenico

-----[ Domenico Andreoli, aka cavok
 --[ http://www.dandreoli.com/gpgkey.asc
   ---[ 3A0F 2F80 F79C 678A 8936  4FEE 0677 9033 A20E BC50
