From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
 submit to upper layer
Date: Sat, 14 Mar 2009 11:45:22 -0700 (PDT)
Message-ID: <20090314.114522.19720687.davem@davemloft.net>
References: <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
	<20090313.191951.228619450.davem@davemloft.net>
	<65634d660903141115w7e164134ycece307f041e93a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: therbert@google.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756832AbZCNSpv@vger.kernel.org>
In-Reply-To: <65634d660903141115w7e164134ycece307f041e93a9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <therbert@google.com>
Date: Sat, 14 Mar 2009 11:15:21 -0700

> I suppose it may be counter-intuitive, but I am not making a general
> claim.  I would only suggest that these software hacks could be a very
> good approximation or substitute for hardware functionality.  This is
> a generic way to get more performance out of deficient or lower end
> NICs.

They certainly could.  Why don't you post the current version
of your patches so we have something concrete to discuss?
