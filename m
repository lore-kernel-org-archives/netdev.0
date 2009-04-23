From: Karsten Keil <karsten-keil@t-online.de>
Subject: Re: [PATCH 3/3] Add reference to CAPI 2.0 standard
Date: Thu, 23 Apr 2009 12:14:14 +0200
Message-ID: <200904231214.16260.karsten-keil@t-online.de>
References: <cover.1240410708.git.keil@b1-systems.de> <f094d823a0fc52e010f99aec720c9144d454c2fa.1240410708.git.keil@b1-systems.de> <20090422173232.ad2b3f49.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	tilman@imap.cc, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout11.t-online.de ([194.25.134.85]:41142 "EHLO
	mailout11.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbZDWKPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 06:15:07 -0400
In-Reply-To: <20090422173232.ad2b3f49.rdunlap@xenotime.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Donnerstag, 23. April 2009 02:32:32 Randy Dunlap wrote:
> On Wed, 22 Apr 2009 16:31:48 +0200 Karsten Keil wrote:
> > Move the entry about CAPI 2.0 to the beginning and add a URL.
> > Incorporate changes suggested by Randy Dunlap, thanks for proofreading.
> >
> > Signed-off-by: Karsten Keil <keil@b1-systems.de>
> > ---
> >  Documentation/isdn/INTERFACE.CAPI |   20 +++++++++++++-------
> >  1 files changed, 13 insertions(+), 7 deletions(-)
> >
> > diff --git a/Documentation/isdn/INTERFACE.CAPI
> > b/Documentation/isdn/INTERFACE.CAPI index 8947ffc..4d802ee 100644
> > --- a/Documentation/isdn/INTERFACE.CAPI
> > +++ b/Documentation/isdn/INTERFACE.CAPI
> > @@ -3,6 +3,11 @@ Kernel CAPI Interface to Hardware Drivers
> >
> >  1. Overview
> >
> > +From the CAPI 2.0 spezification:
>
>                      ~~~~~~~~~~~~~
>
> typo or language?    specification:

Ouch :-(, never add a single line without spell checking.
Will send out a new set, also fix the wrong From: line in the patches from 
Tilman.

...

