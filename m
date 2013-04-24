From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch -next] netfilter: nf_nat: missing condition in
 nf_xfrm_me_harder()
Date: Thu, 25 Apr 2013 01:59:47 +0200
Message-ID: <20130424235947.GA6528@localhost>
References: <20130424151151.GA16783@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39835 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758270Ab3DXX7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 19:59:52 -0400
Content-Disposition: inline
In-Reply-To: <20130424151151.GA16783@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 24, 2013 at 06:11:51PM +0300, Dan Carpenter wrote:
> This if statement was accidentally dropped in a merge commit so now it
> returns unconditionally.

Applied, thanks Dan.
