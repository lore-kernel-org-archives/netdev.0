From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Wed, 25 Jul 2012 01:30:40 +0300
Message-ID: <CAJZOPZKUw7DQQH5mFq4XK5GOZ_Wj6JmjFYi6no7aL_UrpO10vw@mail.gmail.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
	<20120724.140353.1432900101600410863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: klebers@linux.vnet.ibm.com, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	ogerlitz@mellanox.com, cascardo@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com, Shlomo Pongratz <shlomop@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53724 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab2GXWal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 18:30:41 -0400
Received: by yenl2 with SMTP id l2so87530yen.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 15:30:41 -0700 (PDT)
In-Reply-To: <20120724.140353.1432900101600410863.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 25, 2012 at 12:03 AM, David Miller <davem@davemloft.net> wrote:

> Or, you promised an ACK today, I still haven't seen it.

It turned out that reacted we did, but not the ACK way.

Again, code review wise, we intended to ack it, but Shlomo has set
testing environment, under which he had some issues with the patch, as
such he preferred not to ACK it but rather bring up the issues on the
list and sort them out 1st. I thought it would be wrong to over-rule
this preference of him, and this way is fair-enough with the author
and your guide-lines, maybe I had to be more aggressive with ACKing
this, as of the merge window closing coming. So tomorrow.

Or.

> There is no reason Kleber should be penalized and have his work
> miss the merge window just because you guys can't be bothered
> to approve this patch in a reasonable amount of time.
>
> Therefore I'm just going to apply it later today, and don't do this
> with someone's submission ever again, it impedes progress and
> frustrates contributors.
