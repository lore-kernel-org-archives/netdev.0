From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 07:19:25 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204230714530.7811-100000@simon.ratbox.org>
References: <20020423.034450.102874103.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020423.034450.102874103.davem@redhat.com>
List-Id: netdev.vger.kernel.org

I'm *certain* this is a switch, albeit a cheap, unmanaged one, I've got
other devices hanging off of it that are just happy at 100MB/full duplex
right now. Also I am not forcing it to full duplex, this is what it is
trying to do on its own.

Regards,

Aaron

On Tue, 23 Apr 2002, David S. Miller wrote:

>    From: Aaron Sethman <androsyn@ratbox.org>
>    Date: Tue, 23 Apr 2002 07:04:24 -0400 (EDT)
>
>    Its attached to a D-Link mini switch(your average $20 piece of junk).
>
> If it is $20 it isn't a switch, I can assure you
> this. :-)  More seriously, please be sure its' a switch.
>
> 99 out of 100 reports about not getting full duplex turn
> out to be the person is attached to a 100baseT hub, not
> a switch.
>
>

