From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 linux-2.6.35-rc3] ks8842 driver
Date: Sat, 10 Jul 2010 09:25:06 +0900
Message-ID: <20100710002506.GH5443@verge.net.au>
References: <C43529A246480145B0A6D0234BDB0F0D0212A4@MELANITE.micrel.com>
 <20100708075245.GA21371@verge.net.au>
 <C43529A246480145B0A6D0234BDB0F0D481D67@MELANITE.micrel.com>
 <20100708.214101.39178389.davem@davemloft.net>
 <20100709060808.GA20370@verge.net.au>
 <C43529A246480145B0A6D0234BDB0F0D0212A5@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Li, Charles" <Charles.Li@Micrel.Com>
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54788 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab0GJAZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 20:25:10 -0400
Content-Disposition: inline
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D0212A5@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 09, 2010 at 02:22:35PM -0700, Choi, David wrote:
> Hi all,
> 
> I change the ks8842 driver so that the platform private data is used to pass
> different parameters like selection of 16/32bit, as suggested.

Thanks David, that seems a lot nicer to me.
