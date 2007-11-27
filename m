From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 18:15:42 +0100
Message-ID: <20071127171542.GB3406@stusta.de>
References: <20071122343.446909000@suse.de> <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com> <200711271549.37670.rusty@rustcorp.com.au> <1196141742.9876.49.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:41120 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756836AbXK0RPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 12:15:53 -0500
Content-Disposition: inline
In-Reply-To: <1196141742.9876.49.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 11:35:42PM -0600, Tom Tucker wrote:
> On Tue, 2007-11-27 at 15:49 +1100, Rusty Russell wrote:
>...
> > No.  That's the wrong question.  What's the real upside?
> 
> Explicitly documenting what comprises the kernel API (external,
> supported) and what comprises the kernel implementation (internal, not
> supported).
>...

There is not, never was, and never will be, any supported external API 
of the kernel.
 
cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

