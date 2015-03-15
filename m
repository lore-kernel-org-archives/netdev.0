From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip link: Do not show help if 'dev he' was
 specified
Date: Sun, 15 Mar 2015 12:38:31 +0200
Message-ID: <20150315103831.GA4008@angus-think.lan>
References: <1426406515-16171-1-git-send-email-vadim4j@gmail.com>
 <55055DCA.1090108@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org,
	leonhard@pre.is
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34425 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbbCOKuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:50:10 -0400
Received: by lbbsy1 with SMTP id sy1so14733839lbb.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 03:50:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55055DCA.1090108@kristov.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 11:24:10AM +0100, Christoph Schulz wrote:
> Hello!
> 
> On 15.03.2015 09:01, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Date: Sun, 15 Mar 2015 09:11:41 +0200
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > Reported-by: Leonhard Preis <leonhard@pre.is>
> > ---
> >  ip/ipaddress.c | 3 +--
> >  ip/iplink.c    | 6 ++----
> >  2 files changed, 3 insertions(+), 6 deletions(-)
> 
> We use a similar patch at the fli4l router project, but we also modified other files (ip6tunnel.c, ipmaddr.c, ipmroute.c, ipneigh.c, iproute.c, iprule.c). I'm afraid the patch is based on iproute2 3.11.0, but it applies to 3.17.0 (the version we currently use).
> 
> I attach the patch in the hope it will prove useful, perhaps as a base for a follow-up patch of yours.
> 
> 
> Best regards,
> 
> Christoph Schulz
> 

Hi,

It applies on my local master but I did not test it,
so you can re-send it as a complete fix instead of my ?

Thanks,
