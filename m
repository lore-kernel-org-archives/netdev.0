From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: DNS (?) not working on G5 (64-bit powerpc) (was [net-next,v3,3/3] udp: try to avoid 2 cache miss on dequeue)
Date: Mon, 26 Jun 2017 13:15:48 +1000
Message-ID: <87d19rphgb.fsf@concordia.ellerman.id.au>
References: <87shisqihz.fsf@concordia.ellerman.id.au> <1498165026.2503.21.camel@redhat.com> <1498166297.111795.1018373424.5E414246@webmail.messagingengine.com> <87r2ybp4ud.fsf@concordia.ellerman.id.au> <1498219181.2611.6.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:34615 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751525AbdFZDPu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 23:15:50 -0400
In-Reply-To: <1498219181.2611.6.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paolo Abeni <pabeni@redhat.com> writes:
> Thank you!
>
> I'll submit formally the patch after some more testing.

Thanks.

> I noticed this version has entered the ppc patchwork, but I think that
> the formal submission should go towards the net-next tree.

Yeah it picks up all patches sent to the list. That's fine I'll just
mark it "Not applicable", and expect to see it arrive via net-next.

cheers
