From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Mon, 19 May 2008 14:29:38 +0200
Message-ID: <m3r6bya34d.fsf@ursa.amorsen.dk>
References: <87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org> <20080516121239.GA9627@gondor.apana.org.au> <482DB568.1040704@firstfloor.org> <20080517010136.GA15102@gondor.apana.org.au> <482EBAA8.3040506@firstfloor.org> <a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com> <20080517130535.02d45372@infradead.org> <4830014F.9040800@firstfloor.org> <20080518112657.GK16496@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:47520 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758185AbYESM3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 08:29:53 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jy4Ux-0003md-HX
	for netdev@vger.kernel.org; Mon, 19 May 2008 12:29:51 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 19 May 2008 12:29:51 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 19 May 2008 12:29:51 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Theodore Tso <tytso@mit.edu> writes:

> also, mixing in whatever randomness it can get from the mouse during
> the install is also a Really Good Idea.)

I suspect that most server installations are completely automated. No
input device activity at all.


/Benny


