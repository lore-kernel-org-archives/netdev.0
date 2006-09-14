From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Thu, 14 Sep 2006 10:54:59 +0900
Message-ID: <20060914105459.4923d464@localhost.localdomain>
References: <20060908111613.12c1f9b8@localhost.localdomain>
	<450843C6.6030605@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50373 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751331AbWINBzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 21:55:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <450843C6.6030605@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2006 13:45:42 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> applied, then I fixed up all the drivers
> 
> Otherwise, it was a half-complete job that would take years to get 
> cleaned up.
> 
> 

Thanks, I did the same effective patch last night but doing a "make allmodconfig"
build took overnight on a laptop.
