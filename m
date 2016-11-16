From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Tue, 15 Nov 2016 22:30:04 -0500 (EST)
Message-ID: <20161115.223004.1224531760507443618.davem@davemloft.net>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
        <20161115.220108.1225196299725031215.davem@davemloft.net>
        <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cugyly@163.com, netdev@vger.kernel.org
To: Linyu.Yuan@alcatel-sbell.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935055AbcKPDaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:30:06 -0500
In-Reply-To: <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Date: Wed, 16 Nov 2016 03:13:31 +0000

> orginal code means when reqest name have colon, then label name will have colon.

And that is intentional.
