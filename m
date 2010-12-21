From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [STABLE 2.6.32 PATCH] net: release dst entry while
 cache-hot for GSO case too
Date: Mon, 20 Dec 2010 16:07:35 -0800
Message-ID: <20101221000735.GE1678@kroah.com>
References: <20101011.085952.193718228.davem@davemloft.net>
 <4CB33907.5060803@gmail.com>
 <1286814652.2737.41.camel@edumazet-laptop>
 <20101026.115434.241921999.davem@davemloft.net>
 <4D000B0D.2060101@gmail.com>
 <20101208230536.GA8062@kroah.com>
 <4D007A77.8050102@gmail.com>
 <20101209181937.GA24175@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>, krkumar2@in.ibm.com,
	avagin@openvz.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mjt@tls.msk.ru, David Miller <davem@davemloft.net>,
	stable@kernel.org
To: "avagin@gmail.com" <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:49123 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757676Ab0LUAO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 19:14:58 -0500
Content-Disposition: inline
In-Reply-To: <20101209181937.GA24175@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 09, 2010 at 10:19:37AM -0800, Greg KH wrote:
> On Thu, Dec 09, 2010 at 09:43:03AM +0300, avagin@gmail.com wrote:
> > I add the patch in attachments
> 
> Ok, thanks, I'll queue it up for the next .32 release after this one.

Now applied.

greg k-h
