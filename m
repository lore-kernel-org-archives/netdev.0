From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect negative
 mem references
Date: Fri, 30 Mar 2012 17:51:01 +0200
Message-ID: <4F75D665.6050405@googlemail.com>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com> <1332965129.2325.12.camel@edumazet-glaptop> <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com> <1332967172.2325.22.camel@edumazet-glaptop> <4F744D58.3070009@googlemail.com> <1333098711.19659.9.camel@edumazet-laptop> <4F75B828.3090705@googlemail.com> <5D02999E-C16F-4D2B-9007-173AE054E614@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uhura.skim.hs-owl.de ([193.174.118.81]:58250 "EHLO
	uhura.skim.hs-owl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761144Ab2C3QyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 12:54:25 -0400
In-Reply-To: <5D02999E-C16F-4D2B-9007-173AE054E614@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Evans schrieb:
> Hi Jan,
> 
> On 30 Mar 2012, at 14:42, Jan Seiffert <kaffeemonster@googlemail.com> wrote:
> 
[snip]
>> Do you know where i can ping the powerpc guys a little bit harder?
> 
> No need (unless you mean a different guy), I have enough guilt as it
> is! :) (Sorry for no response, am moving house and am netless.)

Oh, ok, didn't know.

> I skimmed your patches on my phone but hope to be in a state to 
> review/test over the weekend or early next week. :)>> 

It would be great if you could review it.
With pinging harder i meant to get anyone fluent in powerpc asm to look
at the changes i made in the asm. I think the stack setup I've done is wrong.

> Cheers,
> 
> Matt
> 

Greetings
	Jan

> 
[snip]

-- 
Real programmer are surprised when their
odometer does not flip over from 000009
to 00000A.
