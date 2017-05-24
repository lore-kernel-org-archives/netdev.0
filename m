From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/5] add tcp flags match support to flower
 and offload it
Date: Wed, 24 May 2017 16:24:16 -0400 (EDT)
Message-ID: <20170524.162416.1565990255865344622.davem@davemloft.net>
References: <20170523164048.16514-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032590AbdEXUYT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 16:24:19 -0400
In-Reply-To: <20170523164048.16514-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 May 2017 18:40:43 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patch adds support to dissect tcp flags, match on them using
> flower classifier and offload such rules to mlxsw Spectrum devices.
> 
> ---
> v1->v2:
> - removed no longer relevant comment from patch 1 as suggested by Or
> - sent correct patches this time

Series applied, thanks.
