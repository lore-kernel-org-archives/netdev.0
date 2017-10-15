From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 4/5] mlxsw: spectrum: router: Add support for
 address validator notifier
Date: Sun, 15 Oct 2017 11:36:47 +0300
Message-ID: <20171015083647.GC10604@shredder.mtl.com>
References: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
 <1507935733-18950-5-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com, davem@davemloft.net,
        yoshfuji@linux-ipv6.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:47127 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751630AbdJOIgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 04:36:50 -0400
Content-Disposition: inline
In-Reply-To: <1507935733-18950-5-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 04:02:12PM -0700, David Ahern wrote:
> Add support for inetaddr_validator and inet6addr_validator. The
> notifiers provide a means for validating ipv4 and ipv6 addresses
> before the addresses are installed and on failure the error
> is propagated back to the user.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
