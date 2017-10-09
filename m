From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000]
Date: Sun, 8 Oct 2017 20:50:16 -0700
Message-ID: <20171008205016.142a679d@cakuba.netronome.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
        <20171008204304.58ec8e5e@cakuba.netronome.com>
        <CANn89i+4iYzw03zKgPCcYNKfonM+HPwiEqQZ97n2vCWUt+Y9Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:13467 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753728AbdJIDuX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 23:50:23 -0400
In-Reply-To: <CANn89i+4iYzw03zKgPCcYNKfonM+HPwiEqQZ97n2vCWUt+Y9Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 8 Oct 2017 20:47:10 -0700, Eric Dumazet wrote:
> This was discussed/reported earlier today by Ido.
> 
> https://patchwork.ozlabs.org/patch/823011/
> 
> We will submit an official fix shortly.

Ah, sorry, I missed that!
