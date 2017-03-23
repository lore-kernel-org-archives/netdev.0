From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 1/2] net: bridge: allow SW learn to take over HW
 fdb entries
Date: Thu, 23 Mar 2017 21:47:13 +0200
Message-ID: <20170323194713.GA25688@splinter.mtl.com>
References: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
 <1490264833-28867-2-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, jiri@resnulli.us,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        roopa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50662 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933031AbdCWTrR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:47:17 -0400
Content-Disposition: inline
In-Reply-To: <1490264833-28867-2-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 12:27:12PM +0200, Nikolay Aleksandrov wrote:
> Allow to take over an entry which was previously learned via HW when it
> shows up from a SW port. This is analogous to how HW takes over SW learned
> entries already.
> 
> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
