From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: TCP sequence number inference attack on Linux
Date: Sat, 22 Dec 2012 03:13:56 +0100
Message-ID: <20121222021356.GG25100@order.stressinduktion.org>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com> <1356114663.21834.7697.camel@edumazet-glaptop> <1356115931.21834.7745.camel@edumazet-glaptop> <CALvgte-=v=bRnQ2HPDxyqxBOjD6DXp_BUySW6Hm7h+81M+RYMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44301 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab2LVCN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 21:13:58 -0500
Content-Disposition: inline
In-Reply-To: <CALvgte-=v=bRnQ2HPDxyqxBOjD6DXp_BUySW6Hm7h+81M+RYMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2012 at 02:13:12PM -0500, Zhiyun Qian wrote:
> That seems like a good idea. I am not sure how it is implemented
> though. Is it a new feature of Linux? Would you mind sending some
> pointers for this?

You can check if network namespaces are in use by looking at about:sandbox in
chrome. It should be enabled by default (don't know about chromium, though).
