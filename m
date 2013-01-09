From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Wed, 09 Jan 2013 10:08:48 +0100
Message-ID: <50ED33A0.8020501@openwrt.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com> <50EACCD3.90609@openwrt.org> <20130107144921.GA31577@hmsreliant.think-freely.org> <50EAEA71.1060007@gmail.com> <20130107154625.GD31577@hmsreliant.think-freely.org> <50EAFA2A.3000200@gmail.com> <50EC5BE7.3090401@openwrt.org> <50EC60B8.4070205@gmail.com> <50EC6378.7020505@inktank.com> <50EC654A.9070506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Elder <elder@inktank.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:49687 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355Ab3AIJLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 04:11:24 -0500
In-Reply-To: <50EC654A.9070506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/08/13 19:28, Vlad Yasevich a =C3=A9crit :
>>> Hi Florian
>>>
>>> Alex Alder already sent the patch that Neil and I both acked, but I=
 see
>>> that Alex never sent it to netdev (just checked the headers).
>>>
>>> Oh well...  this is the same change that Alex sent, so ACK, and now=
 it
>>> can get into the tree.
>>>
>>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>>>
>>> Alex, please be sure to CC your patches to netdev as well.
>>
>> Sorry, I just sent my messages to the addresses listed
>> on the commit that introduced the problem this fixed.
>>
>> Linus already pulled in the patch.
>>
>
> I see.. Then this is a noop ;)

Great, thanks!
--
=46lorian
