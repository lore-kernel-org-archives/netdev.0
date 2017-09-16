From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH] Documentation: fix ascii art in networking docs
Date: Sat, 16 Sep 2017 20:18:15 +0200
Message-ID: <87efr65wyg.fsf@linux-m68k.org>
References: <20170916162217.GA11237@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Netdev list <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:51095 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751253AbdIPSSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 14:18:18 -0400
In-Reply-To: <20170916162217.GA11237@amd> (Pavel Machek's message of "Sat, 16
        Sep 2017 18:22:17 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep 16 2017, Pavel Machek <pavel@ucw.cz> wrote:

> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> index 5e40e1f..6309e90 100644
> --- a/Documentation/networking/switchdev.txt
> +++ b/Documentation/networking/switchdev.txt
> @@ -29,7 +29,7 @@ with SR-IOV or soft switches, such as OVS, are possible.
>                        sw1p1  +  sw1p3  +  sw1p5  +          eth1
>                          +    |    +    |    +    |            +
>                          |    |    |    |    |    |            |
> -                     +--+----+----+----+-+--+----+---+  +-----+-----+
> +                     +--+----+----+----+----+----+---+  +-----+-----+
>                       |         Switch driver         |  |    mgmt   |
>                       |        (this document)        |  |   driver  |
>                       |                               |  |           |
>

This is all mis-aligned.  How about replacing all the thin space
characters by normal spaces?

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
