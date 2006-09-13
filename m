From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Wed, 13 Sep 2006 11:19:48 +0900
Message-ID: <20060913111948.2ab822e8@localhost.localdomain>
References: <20060908111613.12c1f9b8@localhost.localdomain>
	<4506DB63.2040904@pobox.com>
	<20060913110844.42623dcb@localhost.localdomain>
	<4507690E.2030804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60834 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751504AbWIMCUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 22:20:06 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4507690E.2030804@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Sep 2006 22:12:30 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > No, they can pass non-const and everthing works.
> > Changing the ethtool_ops to have const args would require a global change.
> 
> Re-stating previous email:  I need a patch which updates all drivers to 
> declare their ethtool_ops structs const.
> 
> 	Jeff
> 
> 

I'll do one mondo patch for all drivers.
