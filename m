From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] ipv6: fix the debug information in icmpv6_route_lookup
Date: Fri, 11 Jul 2014 14:51:45 +0800
Message-ID: <CAJFZqHwwHc+kOiGv2SQEmo4zTHb7fZjWqJEcBht3myoRbUFYvA@mail.gmail.com>
References: <1405060451-12633-1-git-send-email-roy.qing.li@gmail.com>
	<53BF8816.8010400@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:42603 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbaGKGvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 02:51:46 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so623748qcv.10
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 23:51:46 -0700 (PDT)
In-Reply-To: <53BF8816.8010400@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2014 at 2:45 PM, YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com> wrote:
> No.
> It is used by icmp6_send() and it means icmp6_send() won't
> send back to the original "anycast" source addresses.


Ok, thanks
