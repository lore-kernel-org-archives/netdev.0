From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 2/2] tc/m_tunnel_key: Add dest UDP port to
 tunnel key action
Date: Thu, 15 Dec 2016 14:03:36 +0100
Message-ID: <20161215130335.GA30716@penelope.horms.nl>
References: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
 <1481616467-769-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amirva@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35116 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbcLONDo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 08:03:44 -0500
Received: by mail-wm0-f47.google.com with SMTP id a197so162907225wmd.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 05:03:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481616467-769-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 10:07:47AM +0200, Hadar Hen Zion wrote:
> Enhance tunnel key action parameters by adding destination UDP port.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Reviewed-by: Roi Dayan <roid@mellanox.com>

Hi,

this looks good to me but could you also update tc/m_tunnel_key.c:usage(); ?

With that change:

Reviewed-by: Simon Horman <simon.horman@netronome.com>
