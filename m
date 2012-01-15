From: "Anatoly Sivov" <mm05@mail.ru>
Subject: Re: why does skb->tstamp use getnstimeofday?
Date: Sun, 15 Jan 2012 22:00:59 +0400
Message-ID: <op.v740bxjffzo5me@stalin>
References: <op.v74shh18fzo5me@stalin>
 <1326645750.5287.48.camel@edumazet-laptop> <op.v74z14g2fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Anatoly Sivov" <mm05@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.mail.ru ([94.100.176.180]:47661 "EHLO smtp27.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab2AOSAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 13:00:04 -0500
In-Reply-To: <op.v74z14g2fzo5me@stalin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> some congestion avoidance algorithm quality, I guess.

I mean efficiency, not quality.
