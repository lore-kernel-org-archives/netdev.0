From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] kill net/rxrpc/rxrpc_syms.c
Date: Tue, 20 Feb 2007 12:29:43 +0100
Message-ID: <20070220112943.GS13958@stusta.de>
References: <20070220000639.GF13958@stusta.de> <18861.1171969186@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:36752 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932895AbXBTL3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 06:29:45 -0500
Content-Disposition: inline
In-Reply-To: <18861.1171969186@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 10:59:46AM +0000, David Howells wrote:
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> >  } /* end rxrpc_create_call() */
> > +EXPORT_SYMBOL(rxrpc_create_call);
> 
> A blank line between the end of the function and the EXPORT_SYMBOL please.

Please discuss this with Andrew [1] and tell me what you agreed upon.

> David

cu
Adrian

[1] http://lkml.org/lkml/2006/11/27/293

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

