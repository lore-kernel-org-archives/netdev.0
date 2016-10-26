From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] rocker: fix error return code in
 rocker_world_check_init()
Date: Wed, 26 Oct 2016 17:21:05 -0400 (EDT)
Message-ID: <20161026.172105.9384376046107523.davem@davemloft.net>
References: <1477146666-29671-1-git-send-email-weiyj.lk@gmail.com>
        <20161022153429.GA3657@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, weiyongjun1@huawei.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932977AbcJZVVK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 17:21:10 -0400
In-Reply-To: <20161022153429.GA3657@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 22 Oct 2016 17:34:29 +0200

> Sat, Oct 22, 2016 at 04:31:06PM CEST, weiyj.lk@gmail.com wrote:
>>From: Wei Yongjun <weiyongjun1@huawei.com>
>>
>>Fix to return error code -EINVAL from the error handling
>>case instead of 0, as done elsewhere in this function.
>>
>>Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes: e420114eef4a ("rocker: introduce worlds infrastructure")
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> 
> Dave, you can queue this to -net.

Done, thanks.
