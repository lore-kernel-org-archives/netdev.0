From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [RFC] [IPv6] spelling fix in /proc:
	/proc/sys/net/ipv6/conf/default/temp_prefered_lft
Date: Wed, 19 Mar 2008 18:25:19 -0700
Message-ID: <1205976319.26345.20.camel@localhost>
References: <20080319204227.GF6935@ens-lyon.fr>
	 <20080319.135205.125229102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1547 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbYCTB2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 21:28:55 -0400
In-Reply-To: <20080319.135205.125229102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-03-19 at 13:52 -0700, David Miller wrote:
> From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> Date: Wed, 19 Mar 2008 21:42:27 +0100
> > Here is a patch to fix all the spelling error (prefered -> preferred)
> I think this doesn't add any value.
> If the procfs file name has to remain the same, which it does,
> changing variable and macro names to be different will only
> cause merge conflicts and pain yet have no redeeming value.

I disagree.  Proper spelling has value.
Misspelled words require additional time to read and parse.

Any change can cause merge conflicts.

A simple comment on the proc name use should be added though.


