From: Andrew Morton <akpm@osdl.org>
Subject: Re: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Wed, 24 May 2006 01:52:47 -0700
Message-ID: <20060524015247.0c13f289.akpm@osdl.org>
References: <20060522191759.GD13964@tuxdriver.com>
	<4473E06C.6060804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9108 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932634AbWEXIxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 04:53:21 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4473E06C.6060804@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
>
> John W. Linville wrote:
> > The following changes since commit 353b28bafd1b962359a866ff263a7fad833d29a1:
> >   David S. Miller:
> >         [SPARC]: Add robust futex syscall entries.
> > 
> > are found in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes
> > 
> > Florin Malita:
> >       orinoco: possible null pointer dereference in orinoco_rx_monitor()
> 
> skipping, went in via akpm apparently.

Yes, sorry, I screwed that up - I thought John's pull request went to Linus
and when nothing had happened for 24 hrs, I sent the diff myself.  Doh.

