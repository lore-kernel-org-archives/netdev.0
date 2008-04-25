From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] socket, socketpair w/flags, accept4
Date: Fri, 25 Apr 2008 12:49:12 +0200
Message-ID: <517f3f820804250349m19efe63eqa789aeb359c86f78@mail.gmail.com>
References: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
	 <20080425042957.GA17699@2ka.mipt.ru>
	 <517f3f820804242343g22700872tf31f0c15047e70e2@mail.gmail.com>
	 <20080425105835.62e80537@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Ulrich Drepper" <drepper@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	"Jakub Jelinek" <jakub@redhat.com>
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:2019 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbYDYKtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 06:49:14 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3553343fgb.17
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 03:49:12 -0700 (PDT)
In-Reply-To: <20080425105835.62e80537@core>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/08, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > > What about sigset there too?
>  >
>  > Right.  That was what I was understanding that Alan referred to when
>  > he was talking about paccept()
>
>
> Actually I hadn't thought about the sigset at all.

Oh -- okay then.  I had understood that that was what you were
referring to when you mentioned Jakub's reference to paccept() (which
I took to be analogous with pselect() -- I vaguely remember seeing
this discussed elsewhere also).
