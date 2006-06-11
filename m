From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH] [2.6.17-rc6] Section mismatch in drivers/net/ne.o during
 modpost
Date: Sun, 11 Jun 2006 12:25:04 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0606111224320.13585@yvahk01.tjqt.qr>
References: <200606110051.k5B0pLBI010621@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdunlap@xenotime.net, akpm@osdl.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux01.gwdg.de ([134.76.13.21]:37772 "EHLO linux01.gwdg.de")
	by vger.kernel.org with ESMTP id S1751586AbWFKKZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 06:25:18 -0400
To: Mikael Pettersson <mikpe@it.uu.se>
In-Reply-To: <200606110051.k5B0pLBI010621@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>The messages above are from when I used gcc-4.1.1.
>With gcc-3.2.3 I only see a single warning.
>
FTR, gcc 4.0.x is also 'affected'.


Jan Engelhardt
-- 
