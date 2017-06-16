From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2/net-next] tc: don't print error message on miss
 when parsing control action with default
Date: Fri, 16 Jun 2017 09:08:27 -0700
Message-ID: <20170616090827.780ef02a@xeon-e3>
References: <20170615121051.1877-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34950 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdFPQIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:08:34 -0400
Received: by mail-pg0-f50.google.com with SMTP id k71so22195565pgd.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:08:34 -0700 (PDT)
In-Reply-To: <20170615121051.1877-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 14:10:51 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> In case default control action parsing takes place, it is ok to miss.
> So don't print error message.
> 
> Fixes: e67aba559581 ("tc: actions: add helpers to parse and print control actions")
> Reported-by: Jiri Benc <jbenc@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied to net-next
