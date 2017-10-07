From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/1] ip_tunnel: add mpls over gre support
Date: Sat, 07 Oct 2017 21:39:09 +0100 (WEST)
Message-ID: <20171007.213909.1220990225016361208.davem@davemloft.net>
References: <cover.1507129836.git.amine.kherbouche@6wind.com>
        <e2d0ce36a2e811df680cad29d1ae283b6ba0f13d.1507129836.git.amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, equinox@diac24.net
To: amine.kherbouche@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdJGUj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 16:39:27 -0400
In-Reply-To: <e2d0ce36a2e811df680cad29d1ae283b6ba0f13d.1507129836.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amine Kherbouche <amine.kherbouche@6wind.com>
Date: Wed,  4 Oct 2017 19:35:57 +0200

> This commit introduces the MPLSoGRE support (RFC 4023), using ip tunnel
> API by simply adding ipgre_tunnel_encap_(add|del)_mpls_ops() and the new
> tunnel type TUNNEL_ENCAP_MPLS.
> 
> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>

Applied, thanks.
