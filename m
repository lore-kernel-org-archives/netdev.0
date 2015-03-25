From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 : Don't reduce hop limit below current value
Date: Tue, 24 Mar 2015 21:20:20 -0400 (EDT)
Message-ID: <20150324.212020.1976833070818755805.davem@davemloft.net>
References: <1427232969.3276.4.camel@takeit.se>
	<20150324.180610.1598116015739871982.davem@davemloft.net>
	<1427240198.3276.8.camel@takeit.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ljungmark@modio.se, spider@takeit.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbCYBUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:20:22 -0400
In-Reply-To: <1427240198.3276.8.camel@takeit.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "D. S. Ljungmark" <spider@takeit.se>
Date: Wed, 25 Mar 2015 00:36:38 +0100

> On tis, 2015-03-24 at 18:06 -0400, David Miller wrote:
>> From: "D. S. Ljungmark" <spider@takeit.se>
>> Date: Tue, 24 Mar 2015 22:36:09 +0100
>> 
>> > +		/*	Only set hop_limit on the interface if it is higher than
>> > +		*	the current hop_limit.
>> > +		 */
>> 
>> Comments in the networking should be of the form:
>> 
>> 	/* Like
>> 	 * this.
>> 	 */
> 
> Not sure if your complaint was about the misaligned *, or that there was
> a tab char after the comment start rather than a space.
> 
> Adjusted both and re-sending.

This is not how you resubmit a patch.

When you are asked to make a change in your submission, you must
make a fresh, new, patch posting with full commit message and
Signoffs.
