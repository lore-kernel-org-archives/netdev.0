From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH v2 00/18] gtp: fixes and support multiple VRF's per GTP
 socket
Date: Tue, 24 Jan 2017 16:39:19 +0100
Message-ID: <20170124153919.zkigaq55kykyrfq5@nataraja>
References: <20170124152848.6120-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@netfilter.org>, netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:54593 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXQeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:34:19 -0500
Content-Disposition: inline
In-Reply-To: <20170124152848.6120-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Tue, Jan 24, 2017 at 04:28:30PM +0100, Andreas Schultz wrote:
> During that work some smaller problems where found and fixes for them are
> included.

As this is a rather large patch-set, and I think it might be better to
split it in clear bugfixes of the existing code (or no-brainers like the
module alias) and in introducing new featur regarding socket/netdev.
However, that's just my comment "from the side", I'm not the one who
needs to be convinced in terms of merging them :)

I would just assume that the clear fixes + no-brainers could go in right
away without any further review...

-- 
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
============================================================================
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie
