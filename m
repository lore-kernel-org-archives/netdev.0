From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFT PATCH 0/9] Cleanup and extension of netdev features
Date: Tue, 21 Jun 2011 14:43:28 -0700
Message-ID: <4E011080.7000008@candelatech.com>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43290 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab1FUVnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 17:43:37 -0400
In-Reply-To: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2011 12:14 PM, Micha=C5=82 Miros=C5=82aw wrote:
> This is a preview of the cleanups pending after getting rid of old
> ethtool ops from remaining drivers.

Even when skipping patch 1 (seems this was just merged earlier today),
these patches do not all apply to net-next.

They are also full of white-space warnings.

Please re-post them when you sync against upstream
and I'll try to do some testing.

Also, do you have a cooresponding patch against ethtool
to make it able to handle the new 64-bit flags?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

