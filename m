From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 3/3] net: mvneta: adjust multiline comments to net/ style
Date: Tue, 20 Nov 2012 15:22:03 +0400
Message-ID: <50AB67DB.3030309@mvista.com>
References: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com> <1353322834-16952-4-git-send-email-thomas.petazzoni@free-electrons.com> <50AA2AD4.6030007@mvista.com> <20121119135609.3808b1c7@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:44230 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab2KTLXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 06:23:24 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so1846736lag.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 03:23:23 -0800 (PST)
In-Reply-To: <20121119135609.3808b1c7@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-11-2012 16:56, Thomas Petazzoni wrote:

>>> -/*
>>> - * The two bytes Marvell header. Either contains a special value used
>>> +/* The two bytes Marvell header. Either contains a special value used
>>
>>      Why the heck you're doing this? It's the preferred style, see
>> Documentation/CodingStyle, chapter 8.

> No. Please read Documentation/CodingStyle, chapter 8 entirely:

> ===============================================================
> The preferred style for long (multi-line) comments is:
>
>          /*
>           * This is the preferred style for multi-line
>           * comments in the Linux kernel source code.
>           * Please use it consistently.
>           *
>           * Description:  A column of asterisks on the left side,
>           * with beginning and ending almost-blank lines.
>           */
>
> For files in net/ and drivers/net/ the preferred style for long
> (multi-line) comments is a little different.
>
>          /* The preferred comment style for files in net/ and drivers/net
>           * looks like this.
>           *
>           * It is nearly the same as the generally preferred comment style,
>           * but there is no initial almost-blank line.
>           */
> ===============================================================

> Seen the second part?

    Not until now probably. Sorry for the noise then. :-/

WBR, Sergei
