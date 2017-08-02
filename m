From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 6/6] ipv4: fib: Remove unused functions
Date: Wed, 2 Aug 2017 17:01:36 -0600
Message-ID: <1be7d5e2-f41f-212a-bda1-a64f8f88acfc@gmail.com>
References: <20170802075606.1090-1-jiri@resnulli.us>
 <20170802075606.1090-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33459 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdHBXBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:01:38 -0400
Received: by mail-pg0-f66.google.com with SMTP id u185so7801816pgb.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 16:01:38 -0700 (PDT)
In-Reply-To: <20170802075606.1090-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 1:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Previous patches converted users of these functions to provide offload
> indication using the nexthop's flags instead of the FIB info's.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/ip_fib.h | 13 -------------
>  1 file changed, 13 deletions(-)
> 

Acked-by: David Ahern <dsahern@gmail.com>
