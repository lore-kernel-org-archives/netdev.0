From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 13/14] gtp: Support for GRO
Date: Tue, 19 Sep 2017 20:03:21 +0800
Message-ID: <20170919120321.qiw72rsvpwvtj6n2@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-14-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45341 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751476AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-14-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 05:39:03PM -0700, Tom Herbert wrote:
> Populate GRO receive and GRO complete functions for GTP-Uv0 and v1.

looks fine to me, though I'm not the GRO expert here.  Let's say what
the netdev gurus have to say in their review.

If you say it is tested with GRO-capable and non-GRO capable device
drivers, I'm fine with the patch.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
