From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] af_key: initialize satype in
 key_notify_policy_flush()
Date: Fri, 22 Feb 2013 06:56:57 +0100
Message-ID: <20130222055657.GG17794@secunet.com>
References: <1361201060-31732-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39719 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab3BVF5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 00:57:03 -0500
Content-Disposition: inline
In-Reply-To: <1361201060-31732-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2013 at 04:24:20PM +0100, Nicolas Dichtel wrote:
> This field was left uninitialized. Some user daemons perform check against this
> field.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks!
