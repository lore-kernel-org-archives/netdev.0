From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH iproute2 net-next] iproute: Display offload indication
 per-nexthop
Date: Thu, 3 Aug 2017 08:26:29 -0600
Message-ID: <86fc8356-f5f7-2615-eb12-7b49a2b195d6@gmail.com>
References: <20170803061355.6474-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jiri@mellanox.com, mlxsw@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34453 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdHCO02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 10:26:28 -0400
Received: by mail-pf0-f179.google.com with SMTP id o86so7002245pfj.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 07:26:28 -0700 (PDT)
In-Reply-To: <20170803061355.6474-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/17 12:13 AM, Ido Schimmel wrote:
> Since kernel commit 475abbf1ef67 ("ipv4: fib: Set offload indication
> according to nexthop flags") offload indication is reported on a
> per-nexthop basis.
> 
> Adjust iproute2 to display it.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  ip/iproute.c | 2 ++
>  1 file changed, 2 insertions(+)
> 

Acked-by: David Ahern <dsahern@gmail.com>
