From: Simon Horman <horms@verge.net.au>
Subject: Re: [Patch net-next] ipvs: remove an annoying printk in netns init
Date: Mon, 12 Dec 2016 08:54:21 +0100
Message-ID: <20161212075419.GA10193@verge.net.au>
References: <1481346600-25335-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56859 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbcLLHy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 02:54:28 -0500
Content-Disposition: inline
In-Reply-To: <1481346600-25335-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On vr, dec 09, 2016 at 09:09:59 -0800, Cong Wang wrote:
> At most it is used for debugging purpose, but I don't think
> it is even useful for debugging, just remove it.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks, applied.
