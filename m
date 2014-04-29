From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 10:11:18 -0500
Message-ID: <CAHrpEqSw3iwJj1nHuCJ7LcoL2EUxYqMb-eA1QZN0_WvR-Y_mWA@mail.gmail.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
	<CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
	<20140429141527.GZ26756@n2100.arm.linux.org.uk>
	<CAHrpEqTc6=yS4ApLO7AbZyVq26kGxq+WBcyFjgjbiPySq7055Q@mail.gmail.com>
	<20140429143243.GA26756@n2100.arm.linux.org.uk>
	<CAHrpEqQL7LviXA4_NLNwSBoW84W_vbnzWkc9At5QBqUkqu63yw@mail.gmail.com>
	<20140429150403.GC26756@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36412 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757707AbaD2PLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 11:11:20 -0400
Received: by mail-wg0-f45.google.com with SMTP id b13so358892wgh.28
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 08:11:19 -0700 (PDT)
In-Reply-To: <20140429150403.GC26756@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 10:04 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> I'd just like to see what you're doing.  Note that your submission also
> didn't get through the linux-arm-kernel list either, so I didn't get it
> via that path either.

We have not sent out to public mail list yet.
But there are really big change.
We need support 3 ring queues for tx and rx.

best regards
Frank Li
