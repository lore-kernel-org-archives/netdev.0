From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] mlxsw: spectrum_router: Increase VRF scale
Date: Mon, 14 Aug 2017 11:14:19 -0700 (PDT)
Message-ID: <20170814.111419.240521288014786679.davem@davemloft.net>
References: <20170814085405.1452-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751702AbdHNSOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 14:14:20 -0400
In-Reply-To: <20170814085405.1452-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 14 Aug 2017 10:54:02 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> The purpose of this set is to increase the maximum number of supported VRF
> devices on top of the Spectrum ASIC under different workloads.
> 
> This is achieved by sharing the same LPM tree across all the virtual
> routers for a given L3 protocol (IPv4 / IPv6). The change is explained in
> detail in the third patch. First two patches are small changes to make
> review easier.

Series applied, thank you.
