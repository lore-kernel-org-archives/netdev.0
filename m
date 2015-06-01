From: Frans Klaver <fransklaver@gmail.com>
Subject: Re: 2.6.32.66 tcp regression OOPs
Date: Mon, 1 Jun 2015 09:00:21 +0200
Message-ID: <CAH6sp9O9sqKuamwF38JZLh+K2QKXNB7RRJ8cPtz+1h6MV7foYg@mail.gmail.com>
References: <6.2.5.6.2.20150531210751.0722ad10@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Willy Tarreau <w@1wt.eu>
To: starlight.2015q2@binnacle.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38248 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbFAHAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 03:00:22 -0400
In-Reply-To: <6.2.5.6.2.20150531210751.0722ad10@binnacle.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc: Willy Tarreau]

On Mon, Jun 1, 2015 at 3:26 AM,  <starlight.2015q2@binnacle.cx> wrote:
> Hello,
>
> Apoligies if I have submitted to the wrong lists.
>
> Encountered a regression in
> 2.6.32.66 relative to 2.6.32.65.
>
> Crash eight minutes after boot.
>
> Will responded with additional details
> if the OOPS is not sufficent.
>
> Best Regards
>

Did you bisect it?
