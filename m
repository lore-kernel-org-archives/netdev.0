From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp_mark_lost_retrans
Date: Mon, 01 May 2017 15:10:42 -0400 (EDT)
Message-ID: <20170501.151042.1997320785999410909.davem@davemloft.net>
References: <CABGNecwM2eDJpPLMQZZ3DCsGDO4ktsX-R43dvgTQkd1Etq+WjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: codesoldier1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36234 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEATKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:10:43 -0400
In-Reply-To: <CABGNecwM2eDJpPLMQZZ3DCsGDO4ktsX-R43dvgTQkd1Etq+WjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Smith <codesoldier1@gmail.com>
Date: Mon, 1 May 2017 12:01:33 -0700

> static void tcp_mark_lost_retrans(struct sock *sk)

This function no longer exists in the tree.
