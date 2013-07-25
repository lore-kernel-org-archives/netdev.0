From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 3/3 net-next] bond: cleanup netpoll code
Date: Thu, 25 Jul 2013 09:06:06 -0400
Message-ID: <20130725130606.GC19366@hmsreliant.think-freely.org>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
 <20130724115357.4d4bddcb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37075 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869Ab3GYNGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:06:14 -0400
Content-Disposition: inline
In-Reply-To: <20130724115357.4d4bddcb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 24, 2013 at 11:53:57AM -0700, Stephen Hemminger wrote:
> This started out with fixing a sparse warning, then I realized that
> the wrapper function bond_netpoll_info could just be removed
> by rolling it into the enable code.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
