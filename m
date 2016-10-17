From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: Use list_move_tail instead of
 list_del/list_add_tail
Date: Mon, 17 Oct 2016 15:36:35 -0400 (EDT)
Message-ID: <20161017.153635.798383310340984408.davem@davemloft.net>
References: <1476717471-16261-1-git-send-email-weiyj.lk@gmail.com>
        <BL2PR07MB23068E5DAD844D5FDF31E4518DD00@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        weiyongjun1@huawei.com, everest-linux-l2@qlogic.com,
        netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759318AbcJQThE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 15:37:04 -0400
In-Reply-To: <BL2PR07MB23068E5DAD844D5FDF31E4518DD00@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Mon, 17 Oct 2016 19:10:10 +0000

>> Using list_move_tail() instead of list_del() + list_add_tail().
> 
>> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Thanks.
> Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thanks.
