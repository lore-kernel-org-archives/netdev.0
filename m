From: Jason Liu <liu.h.jason@gmail.com>
Subject: Re: [PATCH 1/1] net/fec: do not pass NULL dev to DMA API
Date: Sat, 2 Apr 2011 16:35:19 +0800
Message-ID: <AANLkTi=FMsH7Px2m9WkRVyHfGZ9MLvgp-XPHu3Amsu7+@mail.gmail.com>
References: <1301726391-7431-1-git-send-email-b29396@freescale.com>
	<20110402.005714.258110130.davem@davemloft.net>
	<20110402083131.GB26533@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	b29396@freescale.com, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47600 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab1DBIfU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 04:35:20 -0400
Received: by iyb14 with SMTP id 14so4301656iyb.19
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2011 01:35:20 -0700 (PDT)
In-Reply-To: <20110402083131.GB26533@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/2 Shawn Guo <shawn.guo@freescale.com>:
> Hi David,
>
> On Sat, Apr 02, 2011 at 12:57:14AM -0700, David Miller wrote:
>>
>> First, your patches never make it to the mailing list because the li=
st
>> server rejects your postings, due to the fact that there are syntax
>> errors in your email headers:
>>
>> Illegal-Object: =A0 =A0 =A0 Syntax error in From: address found on v=
ger.kernel.org:
>> =A0 =A0 =A0 From: =A0 Aisheng.Dong<b29396@freescale.com>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
^-missing end of mailbox
>>
> Yes, we were aware of that the mail did not get distributed by vger
> list. =A0But we do not know why. =A0Thanks for telling.
>
> I'm not quite sure about the "^" indication. =A0Is it telling that th=
ere
> should be a space between display name and mail address?

We should not use A.B <>, instead should use A B <>.

Jason

>
> --
> Regards,
> Shawn
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
