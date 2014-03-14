From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v2 0/12] vti6: prepare namespace and interfamily
 support.
Date: Fri, 14 Mar 2014 10:54:53 +0100
Message-ID: <20140314095453.GI32371@secunet.com>
References: <1394023276-2591-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42882 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605AbaCNJy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:54:56 -0400
Content-Disposition: inline
In-Reply-To: <1394023276-2591-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2014 at 01:41:04PM +0100, Steffen Klassert wrote:
> This patchset prepares vti6 for proper namespace and interfamily support.
> 
> With this patchset vti6 uses the new IPsec protocol multiplexer to
> register it's own receive side hooks for ESP, AH and IPCOMP exactly
> like the ipv4 side does that now.

This is now applied to ipsec-next.
