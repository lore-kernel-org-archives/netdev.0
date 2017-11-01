From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v2 0/4] net: sched: block callbacks follow-up
Date: Wed, 1 Nov 2017 16:18:18 +0100
Message-ID: <20171101151817.ymwfher4lh2pfndv@netronome.com>
References: <20171101104741.2216-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, mlxsw@mellanox.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, michael.chan@broadcom.com,
        ganeshgr@chelsio.com, saeedm@mellanox.com, matanb@mellanox.com,
        leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:50224 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdKAPSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 11:18:21 -0400
Received: by mail-wr0-f195.google.com with SMTP id p96so2222611wrb.7
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 08:18:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101104741.2216-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 11:47:37AM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset does a bit of cleanup of leftovers after block callbacks
> patchset. The main part is patch 2, which restores the original handling
> of tc offload feature flag.

Reviewed-by: Simon Horman <simon.horman@netronome.com>
