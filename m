From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH]drivers:isdn:istream.c Fix typo pice to piece
Date: Tue, 1 Mar 2011 15:47:00 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1103011546420.32580@pobox.suse.cz>
References: <1298269881-2754-1-git-send-email-justinmattock@gmail.com> <alpine.LNX.2.00.1103011521160.32580@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39648 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141Ab1CAOrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 09:47:01 -0500
In-Reply-To: <alpine.LNX.2.00.1103011521160.32580@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Mar 2011, Jiri Kosina wrote:

> > The below patch changes a typo "pice" to "piece"
> > 
> > Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
> > 
> > ---
> >  drivers/isdn/hardware/eicon/istream.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/isdn/hardware/eicon/istream.c b/drivers/isdn/hardware/eicon/istream.c
> > index 18f8798..7bd5baa 100644
> > --- a/drivers/isdn/hardware/eicon/istream.c
> > +++ b/drivers/isdn/hardware/eicon/istream.c
> > @@ -62,7 +62,7 @@ void diva_xdi_provide_istream_info (ADAPTER* a,
> >    stream interface.
> >    If synchronous service was requested, then function
> >    does return amount of data written to stream.
> > -  'final' does indicate that pice of data to be written is
> > +  'final' does indicate that piece of data to be written is
> >    final part of frame (necessary only by structured datatransfer)
> >    return  0 if zero lengh packet was written
> >    return -1 if stream is full
> 
> Applied.

Bah, I had broken local clone of linux-next, I see it's already there.

Sorry for the noise.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
