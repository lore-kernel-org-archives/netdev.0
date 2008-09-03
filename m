From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC 0/3] mv643xx_eth: convert to phylib
Date: Wed,  3 Sep 2008 15:20:09 +0200
Message-ID: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Cc: Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:56363 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752072AbYICNUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:20:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three patches (two to phylib and one to mv643xx_eth.c)
convert the mv643xx_eth driver over to use phylib.  (They depend
on the set of 17 mv643xx_eth patches just sent to the list.)
