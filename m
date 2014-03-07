From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: rename struct xfrm_filter
Date: Fri, 7 Mar 2014 12:27:27 +0100
Message-ID: <20140307112727.GU32371@secunet.com>
References: <20140304170329.51de98ab@nehalam.linuxnetplumber.net>
 <1394126669-4438-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58187 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037AbaCGL1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 06:27:31 -0500
Content-Disposition: inline
In-Reply-To: <1394126669-4438-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2014 at 06:24:29PM +0100, Nicolas Dichtel wrote:
> iproute2 already defines a structure with that name, let's use another one to
> avoid any conflict.
> 
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to ipsec-next, thanks!
