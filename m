From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFT PATCH 0/9] Cleanup and extension of netdev features
Date: Tue, 21 Jun 2011 16:27:35 -0700
Message-ID: <BANLkTi=BaWLWZZu=FWAO-6LPh7Y37pNjrA@mail.gmail.com>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	<4E011080.7000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35267 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757350Ab1FUX1h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 19:27:37 -0400
Received: by fxm17 with SMTP id 17so280638fxm.19
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2011 16:27:36 -0700 (PDT)
In-Reply-To: <4E011080.7000008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/21 Ben Greear <greearb@candelatech.com>:
> On 06/20/2011 12:14 PM, Micha=C5=82 Miros=C5=82aw wrote:
>>
>> This is a preview of the cleanups pending after getting rid of old
>> ethtool ops from remaining drivers.
>
> Even when skipping patch 1 (seems this was just merged earlier today)=
,
> these patches do not all apply to net-next.
>

Not all of patch was merged earlier today, just the update to e1000
and igbvf.  I still have e1000e, igb, ixgb, ixgbe and ixgbevf patches
still being worked on.  I do apologize for delay.

--=20
Cheers,
Jeff
