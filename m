From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/1] r8169: fix the typo in the comment
Date: Thu, 05 Jan 2017 11:25:01 -0500 (EST)
Message-ID: <20170105.112501.2235679369623381300.davem@davemloft.net>
References: <1483603374-16765-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37906 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760786AbdAEQZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:25:08 -0500
In-Reply-To: <1483603374-16765-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Thu,  5 Jan 2017 03:02:54 -0500

> From the realtek data sheet, the PID0 should be bit 0.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied.
