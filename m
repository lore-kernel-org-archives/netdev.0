From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atheros: atl1: use offset_in_page() macro
Date: Mon, 24 Apr 2017 13:58:18 -0400 (EDT)
Message-ID: <20170424.135818.436480766228728833.davem@davemloft.net>
References: <4dbc77ccaaed98b183cf4dba58a4fa325fd65048.1492758503.git.geliangtang@gmail.com>
        <c8746e014d4f7121ab4602548e199f8e8f2fc083.1492758007.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55384 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1173744AbdDXR6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:58:20 -0400
In-Reply-To: <c8746e014d4f7121ab4602548e199f8e8f2fc083.1492758007.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@gmail.com>
Date: Sat, 22 Apr 2017 09:21:10 +0800

> Use offset_in_page() macro instead of open-coding.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied, thanks.
