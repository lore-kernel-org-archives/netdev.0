From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 14:56:05 +0100
Message-ID: <CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
	<87r4jjav00.fsf@xmission.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>
	<878v5r9es7.fsf@xmission.com>
	<5142CE23.9070804@hhi.fraunhofer.de>
	<87ip4t598t.fsf@xmission.com>
	<514326FF.6020205@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:49126 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588Ab3CON4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 09:56:07 -0400
Received: by mail-we0-f180.google.com with SMTP id k14so3181235wer.11
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 06:56:05 -0700 (PDT)
In-Reply-To: <514326FF.6020205@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 15, 2013 at 2:49 PM, Thomas Martitz
<thomas.martitz@hhi.fraunhofer.de> wrote:
> I want the loopback during development of the NIC hardware. Once the NIC is
> done I drop the loopback and the card will be used for real networking.
> Thus, I want the loopback to a) test my driver, and b) test the hardware
> (for each milestone) as I'm implementing it.

Sorry, I still don't get why you need a loopback device for that.

-- 
Thanks,
//richard
