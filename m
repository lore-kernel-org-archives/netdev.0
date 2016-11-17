From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2] net: nsid cannot be allocated for a dead netns
Date: Thu, 17 Nov 2016 09:41:28 +0100
Message-ID: <0fb84877-d43d-736a-c5a8-1ca954f90925@6wind.com>
References: <201611161759.tCk5fdCO%fengguang.wu@intel.com>
 <1479289775-1715-1-git-send-email-nicolas.dichtel@6wind.com>
 <CAM_iQpXzp54gOyiRu4PUcJhLEB3T+TTEL+JLE2PL+oB31ZuCJw@mail.gmail.com>
 <20161116.231722.2198167385156796830.davem@davemloft.net>
 <CAM_iQpUGayFoDSQL2w6bOVKG2q=dSDyf1jQ5LvrYuy7V_y_auA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrey Wagin <avagin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34953 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751884AbcKQIlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 03:41:31 -0500
Received: by mail-wm0-f42.google.com with SMTP id a197so295055791wmd.0
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 00:41:31 -0800 (PST)
In-Reply-To: <CAM_iQpUGayFoDSQL2w6bOVKG2q=dSDyf1jQ5LvrYuy7V_y_auA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/11/2016 à 07:32, Cong Wang a écrit :
[snip]
> since Nicolas' patch doesn't even compile...
It's always surprising how agressive you are, really :(
Can you show me the compilation error of this patch (we are talking about the v2
patch here)?
