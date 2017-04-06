From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] net/sched: Removed unused vlan actions
 definition
Date: Thu, 6 Apr 2017 12:05:37 -0400
Message-ID: <20170406160536.GA21257@vergenet.net>
References: <1491408565-21606-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:38792 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdDFQFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 12:05:40 -0400
Received: by mail-it0-f41.google.com with SMTP id y18so28708938itc.1
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 09:05:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1491408565-21606-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 07:09:25PM +0300, Or Gerlitz wrote:
> Commit c7e2b9689ef "sched: introduce vlan action" added both the
> UAPI values for the vlan actions (TCA_VLAN_ACT_) and these two
> in-kernel ones which are not used, remove them.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
