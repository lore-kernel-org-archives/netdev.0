From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] mlxsw: Add more extack error reporting
Date: Sat, 07 Oct 2017 23:23:50 +0100 (WEST)
Message-ID: <20171007.232350.904331201909553494.davem@davemloft.net>
References: <20171005214000.14022-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751823AbdJGWYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:24:08 -0400
In-Reply-To: <20171005214000.14022-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  5 Oct 2017 23:39:58 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> Add error messages to VLAN and bridge enslavements to help users
> understand why the enslavement failed.

For some reason patch #2 didn't make it to the list and patchwork,
could you please resend (and add in David Ahern's ACK of course).
