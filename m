From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/fec: do not pass NULL dev to DMA API
Date: Sat, 02 Apr 2011 01:35:41 -0700 (PDT)
Message-ID: <20110402.013541.02274640.davem@davemloft.net>
References: <20110402.005714.258110130.davem@davemloft.net>
	<20110402083131.GB26533@S2100-06.ap.freescale.net>
	<AANLkTi=FMsH7Px2m9WkRVyHfGZ9MLvgp-XPHu3Amsu7+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shawn.guo@freescale.com, netdev@vger.kernel.org,
	b29396@freescale.com, linux-arm-kernel@lists.infradead.org
To: liu.h.jason@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754387Ab1DBIgT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 04:36:19 -0400
In-Reply-To: <AANLkTi=FMsH7Px2m9WkRVyHfGZ9MLvgp-XPHu3Amsu7+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jason Liu <liu.h.jason@gmail.com>
Date: Sat, 2 Apr 2011 16:35:19 +0800

> 2011/4/2 Shawn Guo <shawn.guo@freescale.com>:
>> Hi David,
>>
>> On Sat, Apr 02, 2011 at 12:57:14AM -0700, David Miller wrote:
>>>
>>> First, your patches never make it to the mailing list because the l=
ist
>>> server rejects your postings, due to the fact that there are syntax
>>> errors in your email headers:
>>>
>>> Illegal-Object: =A0 =A0 =A0 Syntax error in From: address found on =
vger.kernel.org:
>>> =A0 =A0 =A0 From: =A0 Aisheng.Dong<b29396@freescale.com>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 ^-missing end of mailbox
>>>
>> Yes, we were aware of that the mail did not get distributed by vger
>> list. =A0But we do not know why. =A0Thanks for telling.
>>
>> I'm not quite sure about the "^" indication. =A0Is it telling that t=
here
>> should be a space between display name and mail address?
>=20
> We should not use A.B <>, instead should use A B <>.

Yes, this is also true.

Characters such as "." must not appear in email headers in this
context unless protected by double quotes.
