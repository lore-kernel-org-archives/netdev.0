From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] geneve: add missing rx stats accounting
Date: Fri, 09 Jun 2017 12:50:20 -0400 (EDT)
Message-ID: <20170609.125020.2287687662203118385.davem@davemloft.net>
References: <1496966868-6032-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751645AbdFIQuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:50:22 -0400
In-Reply-To: <1496966868-6032-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Thu,  8 Jun 2017 17:07:48 -0700

> There are few places on the receive path where packet drops and packet
> errors were not accounted for. This patch fixes that issue.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Applied, thank you.
