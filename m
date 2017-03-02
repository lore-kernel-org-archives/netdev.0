From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Thu, 02 Mar 2017 14:43:58 -0800 (PST)
Message-ID: <20170302.144358.779284930067468307.davem@davemloft.net>
References: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daznis@gmail.com,
        lists2009@fnarfbargle.com, jarod@redhat.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41260 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751770AbdCCBtf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 20:49:35 -0500
In-Reply-To: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  2 Mar 2017 12:24:36 -0800

> This restores the ability of setting bond device's mtu to 9000.
> 
> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
> Reported-by: daznis@gmail.com
> Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
> Cc: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
