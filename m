From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2/net-next] tc: don't print error message on miss
 when parsing control action with default
Date: Fri, 16 Jun 2017 10:56:14 +0200
Message-ID: <20170616105614.3c532212@griffin>
References: <20170615121051.1877-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30026 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752170AbdFPI4S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 04:56:18 -0400
In-Reply-To: <20170615121051.1877-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 14:10:51 +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> In case default control action parsing takes place, it is ok to miss.
> So don't print error message.
> 
> Fixes: e67aba559581 ("tc: actions: add helpers to parse and print control actions")
> Reported-by: Jiri Benc <jbenc@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Tested-by: Jiri Benc <jbenc@redhat.com>

Thanks!

 Jiri
