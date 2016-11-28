From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [patch net] sched: cls_flower: remove from hashtable only in
 case skip sw flag is not set
Date: Mon, 28 Nov 2016 17:16:49 +0200
Message-ID: <20161128151649.GA12270@office.localdomain>
References: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        idosch@mellanox.com, eladr@mellanox.com, ogerlitz@mellanox.com,
        hadarh@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33154 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbcK1PQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:16:52 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so19484126wmu.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:16:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 03:40:13PM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Be symmetric to hashtable insert and remove filter from hashtable only
> in case skip sw flag is not set.
> 
> Fixes: e69985c67c33 ("net/sched: cls_flower: Introduce support in SKIP SW flag")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
Reviewed-by: Amir Vadai <amir@vadai.me>
