From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/5] skb data accessors cleanup
Date: Fri, 16 Jun 2017 12:43:23 -0700
Message-ID: <1497642203.10546.16.camel@perches.com>
References: <20170616070747.3332-1-johannes@sipsolutions.net>
         <20170616.115013.1187787408957466917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0173.hostedemail.com ([216.40.44.173]:35823 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752068AbdFPTn0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:43:26 -0400
In-Reply-To: <20170616.115013.1187787408957466917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 11:50 -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Fri, 16 Jun 2017 09:07:42 +0200
> 
> > Over night, Fengguang's bot told me that it compiled all of its many
> > various configurations successfully, and I had done allyesconfig on
> > x86_64 myself yesterday to iron out the things I missed.
> > 
> > So now I think I'm happy with it.

Nice work Johannes. thanks.

Next up: skb_push?
 
> Series applied, thanks!

David, it seems you applied the V2 version of
this patchset.  When you
apply revised patches,
can you please reply to the V2 submission?

It's a bit confusing otherwise.

> I tell ya, spatch appears to be the crack cocaine of Linus kernel
> development.  Once someone gets into some spatch scripting work,
> they can't stop!

True.

Sometimes I use cocci, sometimes I use regexes.
cocci is cool but it can still be pretty slow.
