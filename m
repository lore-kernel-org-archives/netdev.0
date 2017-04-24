From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net/tcp_fastopen: Fix for various TFO
 firewall issues
Date: Mon, 24 Apr 2017 14:27:34 -0400 (EDT)
Message-ID: <20170424.142734.798240634807249124.davem@davemloft.net>
References: <20170420214548.23666-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S976644AbdDXS1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:27:36 -0400
In-Reply-To: <20170420214548.23666-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Thu, 20 Apr 2017 14:45:45 -0700

> Currently there are still some firewall issues in the middlebox
> which make the middlebox drop packets silently for TFO sockets.
> This kind of issue is hard to be detected by the end client.
> 
> This patch series tries to detect such issues in the kernel and disable
> TFO temporarily.
> More details about the issues and the fixes are included in the following
> patches.

Series applied, thanks.
