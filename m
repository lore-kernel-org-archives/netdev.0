From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [STABLE 2.6.32 PATCH] net: release dst entry while
 cache-hot for GSO case too
Date: Thu, 9 Dec 2010 10:19:37 -0800
Message-ID: <20101209181937.GA24175@kroah.com>
References: <20101011.085952.193718228.davem@davemloft.net>
 <4CB33907.5060803@gmail.com>
 <1286814652.2737.41.camel@edumazet-laptop>
 <20101026.115434.241921999.davem@davemloft.net>
 <4D000B0D.2060101@gmail.com>
 <20101208230536.GA8062@kroah.com>
 <4D007A77.8050102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>, krkumar2@in.ibm.com,
	avagin@openvz.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mjt@tls.msk.ru, David Miller <davem@davemloft.net>,
	stable@kernel.org
To: "avagin@gmail.com" <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:32809 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309Ab0LISZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 13:25:54 -0500
Content-Disposition: inline
In-Reply-To: <4D007A77.8050102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 09, 2010 at 09:43:03AM +0300, avagin@gmail.com wrote:
> I add the patch in attachments

Ok, thanks, I'll queue it up for the next .32 release after this one.

greg k-h
