From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Mon, 31 Oct 2016 16:39:16 +0100
Message-ID: <20161031153916.GE9441@lunn.ch>
References: <58176355.7090200@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58792 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944196AbcJaPjS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 11:39:18 -0400
Content-Disposition: inline
In-Reply-To: <58176355.7090200@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 04:29:25PM +0100, Mason wrote:
> Hello everyone,
> 
> I'm using these net drivers:
> 
>   drivers/net/ethernet/aurora/nb8800.c
>   drivers/net/phy/at803x.c
> 
> With a smp8758 board, they work great.
> I've been trying to use them on a different board:
> 
>   same eth PHY (Atheros AR8035)
>   same eth MAC (Aurora SSN8800)
>   different SoC (same base address for MAC block)
> 
> It doesn't work

Rather vague. What does not work? Please describe the symptoms.

       Andrew
