From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [3/9] modpost: Declare the modpost error functions as printf like
Date: Wed, 12 Dec 2007 12:37:58 +1100
Message-ID: <200712121237.59101.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <20071122024308.9B40114D68@wotan.suse.de> <20071210185008.GA17315@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54400 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbXLLBiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 20:38:10 -0500
In-Reply-To: <20071210185008.GA17315@uranus.ravnborg.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 December 2007 05:50:08 Sam Ravnborg wrote:
> On Thu, Nov 22, 2007 at 03:43:08AM +0100, Andi Kleen wrote:
> > This way gcc can warn for wrong format strings
>
> This loks good. Can I get i s-o-b then I will apply it.

Even better, switch the code to the standard warn/warnx/err/errx.

Cheers,
Rusty.
