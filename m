From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 08:19:43 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204230817260.7811-100000@simon.ratbox.org>
References: <20020423.044704.62892217.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020423.044704.62892217.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Hmmm...I just noticed something curious in the dmesg output I hadn't
noticed before now..

PCI: Failed to allocate resource 0(e0000000-dfffffff) for 01:01.0
PCI: Failed to allocate resource 0(e0000000-dfffffff) for 01:02.0
PCI: Failed to allocate resource 1(e0000000-dfffffff) for 01:02.0

I'm not sure if that is normal or not, but those devices are part of the
QFE.

Regards,

Aaron

On Tue, 23 Apr 2002, David S. Miller wrote:

>    From: Aaron Sethman <androsyn@ratbox.org>
>    Date: Tue, 23 Apr 2002 08:11:41 -0400 (EDT)
>
>    This is actually a single cpu Pentium 150 with 96MB ram, compiled
>    uniprocessor of course.
>
> I don't know where to go from here then, it works fine on my
> Athlon and thats the only x86 I have for testing my one qfe
> card.
>

