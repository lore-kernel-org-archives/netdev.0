From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2011-07-27
Date: Fri, 29 Jul 2011 23:20:41 +0200
Message-ID: <CACna6rzSuTnTXidC-1EOMkddmU9pcSpisNQxrMWba8-4qL=BOA@mail.gmail.com>
References: <20110727184920.GB16431@tuxdriver.com>
	<20110727.222247.2000159983502866405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:52651 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab1G2VUm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 17:20:42 -0400
In-Reply-To: <20110727.222247.2000159983502866405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/28 David Miller <davem@davemloft.net>:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 27 Jul 2011 14:49:21 -0400
>
>> Here is a handful of fixes intended for 3.1. =C2=A0This includes a
>> user-visible typo fix, a fix for a user after free in the new pn533
>> NFC driver, a cfg80211 fix for a possible NULL pointer dereference,
>> a fix for an invalid memory access in b43, and another b43 fix for
>> a memory corruption problem.
>>
>> On top of that b43 memory corruption fix, there is a patch to remove
>> BROKEN from the B43_BCMA Kconfig entry, which is key to enabling
>> support for some of the more modern Broadcom wireless hardware.
>> I'm sure the Rafa=C5=82 (and a number of others) would love to see t=
hat
>> merged while the 3.1 merge window is still open as well.
>>
>> Please let me know if there are problems...
>
> Yep, removing BROKEN from b43 seems reasonable.
>
> Pulled, thanks!

Thanks a lot John and David, hope to get some testers now :)

--=20
Rafa=C5=82
