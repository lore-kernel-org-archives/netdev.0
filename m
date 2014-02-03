From: Neal Cardwell <ncardwell@google.com>
Subject: Re: inet_diag_dump_icsk() change seems bogus...
Date: Sun, 2 Feb 2014 20:41:07 -0500
Message-ID: <CADVnQy=W8VZK6+__YUyUZuWkVkKhux_B3ARdPhtxM0SfiUzrCw@mail.gmail.com>
References: <CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
	<1391367154.28432.91.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQymV9R-f3ANtFxbBnsKtD3ytO7QwrOEz7cJAkVkn34ADKQ@mail.gmail.com>
	<20140202.130315.259664831670406274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:47969 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbaBCBlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 20:41:08 -0500
Received: by mail-ea0-f169.google.com with SMTP id h10so3463187eak.0
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 17:41:07 -0800 (PST)
In-Reply-To: <20140202.130315.259664831670406274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 2, 2014 at 4:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Sun, 2 Feb 2014 13:59:06 -0500
>
>> Ah, makes sense. :-) I have a tested version of the patch for pre-3.13
>> kernels if anyone is interested in that.
>
> Please post :-)  Thanks!

Sure. Posted here:

http://patchwork.ozlabs.org/patch/316053/

neal
