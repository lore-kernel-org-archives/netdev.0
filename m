From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 08:00:59 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204230759170.7811-100000@simon.ratbox.org>
References: <20020423.043111.91362293.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020423.043111.91362293.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Initially they came up with 00:00:00:00:00:00, but I did pass a
macaddr=0x08,0x01,0x03,0x01,0x01,0x08, this being a rather arbitrary MAC
address that I know isn't on my network currently.

Regards,

Aaron

On Tue, 23 Apr 2002, David S. Miller wrote:

>    From: Aaron Sethman <androsyn@ratbox.org>
>    Date: Tue, 23 Apr 2002 07:57:00 -0400 (EDT)
>
>    Okay, tried it this time.  It worked for a short period of time, as I
>    could ping the default gateway.  When I tried to ping it from another
>    host, that is when it decided it would go dead.  This time, it did not go
>    crazy and lock the system up at least.  I tried at both full and half
>    duplex, with the same experience.
>
> What MAC address do the qfe interfaces come up with?
>

