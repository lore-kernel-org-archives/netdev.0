From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v4 net-next 01/10] openvswitch: Fix comments for skb->_nfct
Date: Thu, 9 Feb 2017 13:37:59 -0800
Message-ID: <CAPWQB7HFyOA==wxiW0aPC+vnxoJQVhwUAS8DARRHYB9b5V1gig@mail.gmail.com>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org> <1486668121-45709-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:53854 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752559AbdBIVoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:44:38 -0500
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 6C27847B885
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:39:24 +0100 (CET)
Received: from mfilter2-d.gandi.net (mfilter2-d.gandi.net [217.70.178.140])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id D1D881720B4
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:38:22 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter2-d.gandi.net (mfilter2-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 6so-fNKdlMN0 for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 22:38:21 +0100 (CET)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com [209.85.216.180])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 6BC701720AF
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:38:21 +0100 (CET)
Received: by mail-qt0-f180.google.com with SMTP id x49so17237598qtc.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 13:38:21 -0800 (PST)
In-Reply-To: <1486668121-45709-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 February 2017 at 11:21, Jarno Rajahalme <jarno@ovn.org> wrote:
> Fix comments referring to skb 'nfct' and 'nfctinfo' fields now that
> they are combined into '_nfct'.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
