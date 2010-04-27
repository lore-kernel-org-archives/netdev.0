From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-2.6 PATCH] ixgbe: cleanup ethtool autoneg input
Date: Tue, 27 Apr 2010 13:05:25 -0700
Message-ID: <u2n9929d2391004271305y9732d81r8b611fbb9f9e8b9a@mail.gmail.com>
References: <20100427112513.24196.70511.stgit@localhost.localdomain>
	 <20100427.095629.191403481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:46695 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab0D0UF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 16:05:26 -0400
Received: by pwj9 with SMTP id 9so9776109pwj.19
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 13:05:26 -0700 (PDT)
In-Reply-To: <20100427.095629.191403481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 09:56, David Miller <davem@davemloft.net> wrote:
>
> This is also not appropriate for net-2.6, it doesn't fix a
> regression in the regression list and it doesn't fix a catastropic
> crash or failure.
>
> You really have to be kidding me if you thing a patch like this
> is fine this late in the -RC series.
>
> You also aren't even numbering your patches, which is quite a
> transgression when a submission of a set of patches all to the same
> driver and/or files.
> --

My apologies.  My reasoning for not numbering them was that the
patches were not related and not dependent upon each other.

As far as sending the the three patches un-acceptable patches this
late in the -rc series, that was poor judgement on my part, sorry.

-- 
Cheers,
Jeff
