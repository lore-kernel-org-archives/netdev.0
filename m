From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] arp: fix a regression in arp_solicit()
Date: Mon, 24 Dec 2012 09:21:40 +0800
Message-ID: <CAM_iQpW8WZqZmxycXzgtaOcLrVHPU9kRgJvK0777SyQ8SN155A@mail.gmail.com>
References: <1356273778-19113-1-git-send-email-xiyou.wangcong@gmail.com>
	<CA+icZUWKNAGe+jMbsonrigVZ5Sk7dDdciZn1r7oMcsAWe7i3fQ@mail.gmail.com>
	<CA+icZUXo+OQ4XZ8V588FHKrDanqwq8jR1pAHwVPjJcu+14TKeQ@mail.gmail.com>
	<20121223.141706.1783471119472317669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sedat.dilek@gmail.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	edumazet@google.com, Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:54397 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab2LXBVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 20:21:40 -0500
Received: by mail-da0-f54.google.com with SMTP id n2so2913430dad.13
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 17:21:40 -0800 (PST)
In-Reply-To: <20121223.141706.1783471119472317669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 24, 2012 at 6:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Sedat Dilek <sedat.dilek@gmail.com>
> Date: Sun, 23 Dec 2012 15:58:52 +0100
>
>> While at it you might enhance the label with "ipv4"?
>
> That's excessive.
>
> ARP is ipv4 and ipv4 only, in other protocols it has completely
> different names.

Agreed. I will resend the patch with the typo fixed.

Thanks.
