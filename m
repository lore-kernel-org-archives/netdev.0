From: Rafael Aquini <aquini@linux.com>
Subject: Re: [PATCH net-next-2.6] net/bonding: adjust codingstyle for bond_3ad
 files
Date: Wed, 11 May 2011 21:48:41 -0300
Message-ID: <20110512004839.GB2435@x61.tchesoft.com>
References: <20110511225208.GA18851@x61.tchesoft.com>
 <20110511172814.714e2f2a@nehalam>
Reply-To: aquini@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Joe Perches <joe@perches.com>,
	kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Nicolas Kaiser <nikai@nikai.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:53470 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab1ELAwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 20:52:17 -0400
Content-Disposition: inline
In-Reply-To: <20110511172814.714e2f2a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy Stephen,

On Wed, May 11, 2011 at 05:28:14PM -0700, Stephen Hemminger wrote:
> 
> This should be split into three separate patches.
> 
> Always assume your change will break something for somebody and it will
> be necessary for some later investigation to bisect out the cause.

I'd like to know what are your suggestios to split it.
1. patch for comments;
2. patch for simplification (Nicolas);
3. patch for other adjusts (macro replacement, uninitialized vars...)

Would this approach really be productive?

Thanks in advance.

Cheers!
-- 
Rafael Aquini <aquini@linux.com>
