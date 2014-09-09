From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iwlwifi no authentication with AP - Re: pull request:
 wireless-next 2014-09-08
Date: Wed, 10 Sep 2014 01:07:22 +0300
Message-ID: <CAMw6YJLeO1JZeY6hNe-TXOS56b-otk+htt5VPPor+9iYCQz53Q@mail.gmail.com>
References: <20140908191630.GB29412@tuxdriver.com>
	<540F5927.7000306@hartkopp.net>
	<CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg@mail.gmail.com>
	<540F61D0.9000704@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Emmanuel Grumbach <egrumbach@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:37034 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbaIIWHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 18:07:23 -0400
In-Reply-To: <540F61D0.9000704@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have the same issue with iwlwifi.

On Tue, Sep 9, 2014 at 11:23 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> On 09.09.2014 22:02, Emmanuel Grumbach wrote:
>> On Tue, Sep 9, 2014 at 10:46 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>>> Hello John, all,
>>>
>>> on my i7 Laptop with iwlwifi the latest net-next does not connect to my access point:
>>
>> Are you sure this wasn't the case before?
>
> Indeed I moved to net-next right today - as I also had the LED lockdep splat
> on 3.17-rcX with X < 4.
>
> So it can be that this issue was already introduced at the beginning of this
> net-next cycle. Don't know, sorry. The latest 3.17-rc4 from Linus' tree works
> fine. I'm running a Debian unstable here (in both cases).
>
>> Can you bisect?
>
> Not really. I'm running the kernel on my bare machine - and I just wanted to
> go to bed right now ...
>
> So I will be able to test patches tomorrow morning again.
>
> Tnx for your fast feedback,
> Oliver
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
