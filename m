From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 15:16:26 +0100
Message-ID: <CAFLxGvyCFHk=vhNYCY8obrVJR2rW9M7+J_ppyVpFq3AHAxjRjA@mail.gmail.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
	<87r4jjav00.fsf@xmission.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>
	<878v5r9es7.fsf@xmission.com>
	<5142CE23.9070804@hhi.fraunhofer.de>
	<87ip4t598t.fsf@xmission.com>
	<514326FF.6020205@hhi.fraunhofer.de>
	<CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com>
	<51432B72.20408@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:55575 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab3COOQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 10:16:27 -0400
Received: by mail-we0-f177.google.com with SMTP id d7so3251296wer.22
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 07:16:26 -0700 (PDT)
In-Reply-To: <51432B72.20408@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 15, 2013 at 3:08 PM, Thomas Martitz
<thomas.martitz@hhi.fraunhofer.de> wrote:
> What's wrong with loopback? It's the simplest method to get basic
> bidirectional data transfer going.
>
> Can you suggest an alternative approach?

The real question is, why do you need a second one?
I assume your driver (for the non-existing hardware) is a ethernet driver,
and now you're looking for a way to test your shiny new ethX device, correct?

-- 
Thanks,
//richard
