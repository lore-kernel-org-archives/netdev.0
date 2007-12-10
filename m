From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [3/9] modpost: Declare the modpost error functions
	as printf like
Date: Mon, 10 Dec 2007 19:58:04 +0100
Message-ID: <20071210185804.GB32466@bingen.suse.de>
References: <20071122343.446909000@suse.de> <20071122024308.9B40114D68@wotan.suse.de> <20071210185008.GA17315@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rusty@rustcorp.com.au
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:36814 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329AbXLJS6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 13:58:07 -0500
Content-Disposition: inline
In-Reply-To: <20071210185008.GA17315@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2007 at 07:50:08PM +0100, Sam Ravnborg wrote:
> On Thu, Nov 22, 2007 at 03:43:08AM +0100, Andi Kleen wrote:
> > 
> > This way gcc can warn for wrong format strings
> 
> This loks good. Can I get i s-o-b then I will apply it.

Sorry must have been left out by mistake.

Signed-off-by: Andi Kleen <ak@suse.de>

for both patches.

-Andi

