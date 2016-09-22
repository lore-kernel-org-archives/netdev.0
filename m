From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v3 0/2] Rename WORD_TRUNC/ROUND macros and use them
Date: Thu, 22 Sep 2016 03:13:58 -0400 (EDT)
Message-ID: <20160922.031358.1800247219455760228.davem@davemloft.net>
References: <cover.1474457954.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com, David.Laight@ACULAB.COM
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754482AbcIVHOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 03:14:02 -0400
In-Reply-To: <cover.1474457954.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 21 Sep 2016 08:45:54 -0300

> This patchset aims to rename these macros to a non-confusing name, as
> reported by David Laight and David Miller, and to update all remaining
> places to make use of it, which was 1 last remaining spot.
> 
> v3:
> - Name it SCTP_PAD4 instead of SCTP_ALIGN4, as suggested by David Laight
> v2:
> - fixed 2nd patch summary
> 
> Details on the specific changelogs.

Looks good, applied, thanks!
