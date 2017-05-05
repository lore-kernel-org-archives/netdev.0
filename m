From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 v2 0/2] devlink: Add support for pipeline
Date: Fri, 5 May 2017 09:50:59 -0700
Message-ID: <20170505095059.2551afdd@xeon-e3>
References: <1493810723-2536-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, davem@davemloft.net,
        mlxsw@mellanox.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35154 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdEEQvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:51:07 -0400
Received: by mail-pf0-f173.google.com with SMTP id v14so5225600pfd.2
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 09:51:06 -0700 (PDT)
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

Applied thanks.
