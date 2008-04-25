From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] socket, socketpair w/flags, accept4
Date: Fri, 25 Apr 2008 10:58:35 +0100
Message-ID: <20080425105835.62e80537@core>
References: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
	<20080425042957.GA17699@2ka.mipt.ru>
	<517f3f820804242343g22700872tf31f0c15047e70e2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Ulrich Drepper" <drepper@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	"Michael Kerrisk" <mtk.manpages@gmail.com>,
	"Jakub Jelinek" <jakub@redhat.com>
To: "Michael Kerrisk" <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:59182 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760173AbYDYKGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 06:06:21 -0400
In-Reply-To: <517f3f820804242343g22700872tf31f0c15047e70e2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > What about sigset there too?
> 
> Right.  That was what I was understanding that Alan referred to when
> he was talking about paccept()

Actually I hadn't thought about the sigset at all. 

Alan
--
        "I work for a government agency so please forgive me for not
                 having the latest version of the kernel."
                                -- Ryan Clayburn
