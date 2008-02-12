From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 auto-negotiation problem
Date: Tue, 12 Feb 2008 23:20:15 +0100
Message-ID: <20080212222015.GA21495@electric-eye.fr.zoreil.com>
References: <BAY107-W4033FF1A4417D61C5177FD5310@phx.gbl> <20080203184525.GA12607@electric-eye.fr.zoreil.com> <BAY107-W2892B3D06485CBB5AEDCC2D52B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: fgnijuhhu guduggurehug <jsmiths1234@live.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37999 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751871AbYBLWib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 17:38:31 -0500
Content-Disposition: inline
In-Reply-To: <BAY107-W2892B3D06485CBB5AEDCC2D52B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fgnijuhhu guduggurehug <jsmiths1234@live.com> :
> > fgnijuhhu guduggurehug  :
> > [...]
> >> I already posted my problem and what I did to solve it on
> >> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=461429.
> >
> > Have you tried anything more recent than a 2.6.18 based kernel ?
> 
> No, but if changes were made to the iniatialization of the chipset
> in the current driver (mine was 2.2LK), this might do the trick.

Please try a recent kernel. Your r8169 driver is badly outdated.

[...]
> Anyway, how to best upgrade the kernel in debian (without problems,
> of course) ? The problem right now is that every apt-get upgrade
> reverts the r8169 driver to the old one...

I do not use debian but you can read:

http://www.google.com/search?q=debian+kernel+upgrade

-- 
Ueimor
