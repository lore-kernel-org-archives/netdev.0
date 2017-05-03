From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 v2 0/2] devlink: Add support for pipeline
Date: Wed, 3 May 2017 09:32:59 -0700
Message-ID: <20170503093259.2a1f1a75@xeon-e3>
References: <1493810723-2536-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, davem@davemloft.net,
        mlxsw@mellanox.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35507 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdECQdE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 12:33:04 -0400
Received: by mail-pf0-f181.google.com with SMTP id v14so15076381pfd.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 09:33:04 -0700 (PDT)
In-Reply-To: <1493810723-2536-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 May 2017 13:25:21 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Arkadi says:
> 
> Add support for pipeline debug (dpipe). As a preparation step the netlink
> attribute validation was changed before adding new dpipe attributes.
> ---
> v1->v2
> - Change netlink attribute validation. 
> - Fix commit message typos
> 
> Arkadi Sharshevsky (2):
>   devlink: Change netlink attribute validation
>   devlink: Add support for pipeline debug (dpipe)
> 
>  devlink/devlink.c | 1450 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 1281 insertions(+), 169 deletions(-)
> 

Looks good applied.
