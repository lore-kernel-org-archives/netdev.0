From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: socket: preferred __aligned(size) for control
 buffer
Date: Thu, 08 Dec 2016 18:21:34 -0500 (EST)
Message-ID: <20161208.182134.1053663468494530470.davem@davemloft.net>
References: <1481201513-20783-1-git-send-email-kushwaha.a@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akkushwaha9896@gmail.com
To: kushwaha.a@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45384 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932964AbcLHXVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 18:21:36 -0500
In-Reply-To: <1481201513-20783-1-git-send-email-kushwaha.a@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kushwaha.a@samsung.com
Date: Thu, 08 Dec 2016 18:21:53 +0530

> From: Amit Kushwaha <kushwaha.a@samsung.com>
> 
> This patch cleanup checkpatch.pl warning
> WARNING: __aligned(size) is preferred over __attribute__((aligned(size)))
> 
> Signed-off-by: Amit Kushwaha <kushwaha.a@samsung.com>

Applied to net-next.
