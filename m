From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6 v2] IPv6: Temp addresses are immediately
 deleted.
Date: Tue, 26 Oct 2010 12:38:52 -0700 (PDT)
Message-ID: <20101026.123852.58436932.davem@davemloft.net>
References: <20100927171010.GB7106@adams.ccsl.carleton.ca>
	<20100928.233028.112599117.davem@davemloft.net>
	<201010161442.18748.gwurster@scs.carleton.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gwurster@scs.carleton.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201010161442.18748.gwurster@scs.carleton.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glenn Wurster <gwurster@scs.carleton.ca>
Date: Sat, 16 Oct 2010 14:42:17 -0400

> No, the first patch was to create a temporary address if none exists.  Like 
> Brian Haley pointed out, that patch accommodates the case where we set 
> use_tempaddr to a non-zero value after the interface had been brought up.
> 
> This patch accommodates the case where the router is only broadcasting 
> advertisements every x seconds, and yet the user has set the valid_lft to be 
> something less than x.

Ok, thanks for your patience.

I've applied both of your patches, thanks.
