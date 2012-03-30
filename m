From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect negative
 mem references
Date: Fri, 30 Mar 2012 10:11:19 -0400
Message-ID: <CA+5PVA7+Wxv=L0680BZBN=MOnjk7Gri0aCfr2T9oaNxqS=G-EA@mail.gmail.com>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
	<1332965129.2325.12.camel@edumazet-glaptop>
	<CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>
	<1332967172.2325.22.camel@edumazet-glaptop>
	<4F744D58.3070009@googlemail.com>
	<1333098711.19659.9.camel@edumazet-laptop>
	<4F75B828.3090705@googlemail.com>
	<1333116493.2325.2125.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jan Seiffert <kaffeemonster@googlemail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:56836 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759684Ab2C3OLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 10:11:20 -0400
In-Reply-To: <1333116493.2325.2125.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 30, 2012 at 10:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-03-30 at 15:42 +0200, Jan Seiffert wrote:
>
>> Do you know where i can ping the powerpc guys a little bit harder?
>
> maybe using CC linux-arch@vger.kernel.org

Or linuxppc-dev@lists.ozlabs.org

josh
