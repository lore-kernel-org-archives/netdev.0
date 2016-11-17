From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2] net: nsid cannot be allocated for a dead netns
Date: Thu, 17 Nov 2016 09:39:30 +0100
Message-ID: <60b84320-982c-c288-858f-a653be17cd65@6wind.com>
References: <201611161759.tCk5fdCO%fengguang.wu@intel.com>
 <1479289775-1715-1-git-send-email-nicolas.dichtel@6wind.com>
 <CAM_iQpXzp54gOyiRu4PUcJhLEB3T+TTEL+JLE2PL+oB31ZuCJw@mail.gmail.com>
 <20161116.231722.2198167385156796830.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: avagin@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35923 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbcKQIjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 03:39:33 -0500
Received: by mail-wm0-f52.google.com with SMTP id g23so295348628wme.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 00:39:33 -0800 (PST)
In-Reply-To: <20161116.231722.2198167385156796830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/11/2016 à 05:17, David Miller a écrit :
[snip]
> Indeed, this looks cleaner, Nicolas?
Yes, I agree. Cong already sent a v3 of my patch, let's apply it.
