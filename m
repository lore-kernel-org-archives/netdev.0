From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [git patches] net driver fixes
Date: Fri, 23 Mar 2007 22:56:31 +0100 (CET)
Message-ID: <Pine.LNX.4.60.0703232254170.5971@poirot.grange>
References: <20070323065742.GA17613@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:51641 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934324AbXCWV4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 17:56:33 -0400
In-Reply-To: <20070323065742.GA17613@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff, might be worth getting the sk_buff leak fix in ppp from 
http://www.spinics.net/lists/netdev/msg27706.html in 2.6.21 too?

Don't know how important it is for stable. It was present in 2.6.18 too.

Thanks
Guennadi
---
Guennadi Liakhovetski
