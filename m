From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 24 May 2006 08:42:28 -0400
Message-ID: <20060524124223.GB10156@tuxdriver.com>
References: <20060522191759.GD13964@tuxdriver.com> <20060522191942.GE13964@tuxdriver.com> <4473E288.3030005@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:59655 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932301AbWEXMmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 08:42:42 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4473E288.3030005@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 24, 2006 at 12:35:20AM -0400, Jeff Garzik wrote:
> John W. Linville wrote:
> >The following changes since commit 
> >01d654d25d23fb73deb7904ce1c0b3a0f5fc2908:
> >  John W. Linville:
> >        Merge branch 'upstream-fixes' into upstream
> >
> >are found in the git repository at:
> >
> >  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git 
> >  upstream
> >
> >Marcin Juszkiewicz:
> >      hostap: new pcmcia IDs
> >
> > drivers/net/wireless/hostap/hostap_cs.c |    6 ++++++
> > 1 files changed, 6 insertions(+), 0 deletions(-)
> 
> WTF???  I pull, and see diffstat:
> 
> Merge db21e578e551421d76641d72cb3f8296ed3f9e61, made by recursive.
>  drivers/net/wireless/airo.c                     |    2
...

> This is vastly different from any 'pull upstream' email I've received 
> from you.  It is extremely uncool for me to pull, and receive something 
> other than what your email specified.

Jeff, I am terribly sorry.  I sent a request for this on 24 April,
but it does not appear in the archives.  It must have been dropped
(probably due to size) by the netdev list filters, and I neglected
to notice.

/me wishes the list would send me a note when it drops stuff due
to size...

> Nonetheless, I looked over the changes and they look OK, so I took the 
> lazy route and kept them.
 
I greatly appreciate that!

> For the future, I would perhaps recommend creating an upstream-jeff 
> branch at the time of submission, if you insist upon continuing to push 

The point is well taken.  It probably does make sense either to have an
upstream-jeff branch or to make a new branch if you haven't yet pulled.
I'll keep that in mind.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
