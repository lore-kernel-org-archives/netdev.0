From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Add oif to dst lookups
Date: Wed, 12 Aug 2015 12:26:45 +0200
Message-ID: <20150812102645.GC25499@secunet.com>
References: <1439247491-80410-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44012 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130AbbHLK0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 06:26:48 -0400
Content-Disposition: inline
In-Reply-To: <1439247491-80410-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 04:58:11PM -0600, David Ahern wrote:
> Rules can be installed that direct route lookups to specific tables based
> on oif. Plumb the oif through the xfrm lookups so it gets set in the flow
> struct and passed to the resolver routines.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied to ipsec-next, thanks a lot!
