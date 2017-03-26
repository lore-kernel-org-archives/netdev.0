From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] GTP SGSN-side tunnel
Date: Sat, 25 Mar 2017 20:13:17 -0700 (PDT)
Message-ID: <20170325.201317.114625190800188227.davem@davemloft.net>
References: <20170324222321.28618-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdCZDNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 23:13:51 -0400
In-Reply-To: <20170324222321.28618-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Fri, 24 Mar 2017 23:23:19 +0100

> Changes since v4:
> 
> * Respin the series on top of net-next; the conflicts were trivial,
>   amounting to just code having been shifted about

Series applied, but you really have to make improvements to your header
postings.

First of all, what is the point of only listing the most recent "v4"
changes entry?  Leave every single changes entry in there, it's
history information and useful to people reviewing the series.

Also, this posting also requires that you explain, in detail, at
a high level, what the patch series is doing, how it is doing it,
and why it is doing it that way.

It should be written in a way that a skilled programmer, after
reading it, can probably predict what your patches look like.  It
is an assistance to comprehension and understanding of your changes
and an essential part of patch series submission.

Thank you.
