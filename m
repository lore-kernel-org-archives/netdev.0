From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: 3.1.0-rc2: irq/112-eth0-Tx: page allocation failure: (w/frame
 pointers enabled)
Date: Sat, 3 Sep 2011 06:06:41 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1109030605590.1448@p34.internal.lan>
References: <alpine.DEB.2.02.1108260802590.14539@p34.internal.lan> <201109031049.00728.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alan Piszcz <ap@solarrain.com>
To: Maciej Rutecki <maciej.rutecki@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201109031049.00728.maciej.rutecki@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 3 Sep 2011, Maciej Rutecki wrote:

> On pi?tek, 26 sierpnia 2011 o 14:14:12 Justin Piszcz wrote:
>> Hello,
>>
>> Why does this occur on a machine with 48GB of memory (used mainly as a
>> router) and backup server, is it a kernel bug?
>>
>
> It's regression? Any older kernel works OK?

Hi,

It has been occurring since 'threadirqs' was enabled.

Justin.
