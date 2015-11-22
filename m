From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Mon, 23 Nov 2015 00:02:44 +0100
Message-ID: <20151122230244.GA12249@electric-eye.fr.zoreil.com>
References: <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151120024616.GL7136@marvin.atrad.com.au>
 <20151120224534.GA25025@electric-eye.fr.zoreil.com>
 <20151121223627.GA3493@electric-eye.fr.zoreil.com>
 <20151122225039.GE2957@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35800 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbKVXCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 18:02:53 -0500
Content-Disposition: inline
In-Reply-To: <20151122225039.GE2957@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> I'm a little confused though as to which patch you want me to apply.  There
> was an inline patch against r8169.c in your message, and then there was
> another patch to r8169.c in the form of an attachment.  Both patches removed
> the include of asm/system.h but the rest of the content differs.  Did you
> want each tried in turn?  Apologies if I'm missing something obvious.

Use the inlined one. I forgot to remove the 2.6.35.11 based attachment.

-- 
Ueimor
