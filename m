From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net/bonding: adjust codingstyle for
 bond_3ad files
Date: Wed, 11 May 2011 17:59:12 -0700
Message-ID: <1305161952.19586.231.camel@Joe-Laptop>
References: <20110511225208.GA18851@x61.tchesoft.com>
	 <20110512015237.32d6d92b@absol.kitzblitz>
	 <20110512001858.GA2435@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	Nicolas Kaiser <nikai@nikai.net>,
	netdev <netdev@vger.kernel.org>
To: Rafael Aquini <aquini@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1489 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815Ab1ELA7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 20:59:14 -0400
In-Reply-To: <20110512001858.GA2435@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-11 at 21:18 -0300, Rafael Aquini wrote:
> My bad, sorry. I'll be re-posting soon.

When you repost, it's considered useful and polite to have a
version # in the [PATCH net-next-2.6 v#] subject line

And add a changelog describing what's different in this version
below your sign-off is also good form.

The changelog doesn't get put into git history, but it's useful
for others to see what you've changed so reviewers can skip over
stuff that's been previously commented on and find the new stuff
easier.

Generally the email body contains

verbose patch description

Signed-off-by: you
Any Acks/Reviewed-bys: others

--- ( <- 3 dashes as a separator)

patch changelog if it exists

patch

cheers, Joe

