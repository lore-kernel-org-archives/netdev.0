From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: WAN: Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't exist
Date: Wed, 9 Jul 2008 16:45:34 -0400
Message-ID: <20080709204534.GF31126@csclub.uwaterloo.ca>
References: <m3r6ac3xs8.fsf@maximus.localdomain> <20080709144432.GD31126@csclub.uwaterloo.ca> <m3y74aiy9y.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:51482 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574AbYGIUpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 16:45:35 -0400
Content-Disposition: inline
In-Reply-To: <m3y74aiy9y.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 10:43:37PM +0200, Krzysztof Halasa wrote:
> It seems Cyclades Cyclom 2X (ISA only?) cards use the wanpipe/wanrouter
> thing for X.25. I don't know exact status, though.

Oh OK,  Nifty.  I thought it was all just sangoma stuff, but I guess if
it's in the kernel there is no reason others couldn't use bits of it
too.  Hmm, maybe the sangoma specific stuff has already been cleaned up
then although that CONFIG_WANPIPE_MULTPPP is certainly one of their
bits.

-- 
Len Sorensen
