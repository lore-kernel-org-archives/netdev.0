From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] tc: flower: add support for tcp flags
Date: Tue, 30 May 2017 17:43:09 -0700
Message-ID: <20170530174309.1e78a104@xeon-e3>
References: <20170523164048.16514-1-jiri@resnulli.us>
        <20170523215139.2019-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        yotamg@mellanox.com, mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36708 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdEaAnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:43:12 -0400
Received: by mail-pf0-f172.google.com with SMTP id m17so1906746pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:43:12 -0700 (PDT)
In-Reply-To: <20170523215139.2019-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 May 2017 23:51:39 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Allow user to insert a flower classifier filter rule which includes
> match for tcp flags.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied to net-next
