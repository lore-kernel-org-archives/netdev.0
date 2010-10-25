From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v1] can: Topcliff: Update PCH_CAN driver
	to 2.6.35
Date: Mon, 25 Oct 2010 09:06:46 +0200
Message-ID: <4CC52C86.1050205@grandegger.com>
References: <4CB8506C.3060600@dsn.okisemi.com>	<20101024.144312.104048720.davem@davemloft.net>	<4CC4ADA5.8@pengutronix.de>
	<20101024.150905.39179588.davem@davemloft.net>
	<4CC4AFF9.90009@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	chripell-VaTbYqLCNhc@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CC4AFF9.90009-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/25/2010 12:15 AM, Marc Kleine-Budde wrote:
> On 10/25/2010 12:09 AM, David Miller wrote:
>> From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Date: Mon, 25 Oct 2010 00:05:25 +0200
>>
>>> On 10/24/2010 11:43 PM, David Miller wrote:
>>>> From: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>>>> Date: Fri, 15 Oct 2010 22:00:28 +0900
>>>>
>>>>> CAN driver of Topcliff PCH
>>>>>
>>>>> Topcliff PCH is the platform controller hub that is going to be used in
>>>>> Intel's upcoming general embedded platform. All IO peripherals in
>>>>> Topcliff PCH are actually devices sitting on AMBA bus. 
>>>>> Topcliff PCH has CAN I/F. This driver enables CAN function.
>>>>>
>>>>> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>>>>
>>>> Applied, thanks.
>>>
>>> IMHO this driver needs some improvements. There are some open points
>>> from Wolfgangs and my review. On the other side, it's a new driver and
>>> there's some time left before it hits mainline.
>>
>> When people have more than a week to review and provide feedback,
>> and don't, I have zero sympathy especially this early in the
>> release cycle.
> 
> Let me see....Crap, it's my fault, I just replied to the socketcan
> mailinglist ;( [1]
> 
>> So if adding it to the tree is what I have to do to get you guys to
>> post your comments and suggest fixes, then that's what I am going to
>> (continue) to do. :-)
> 
> ...or to learn how to reply properly :)

Ah, oh, and I added my review to yours :-(. Sorry, for the inconvenience
it caused:

https://lists.berlios.de/pipermail/socketcan-core/2010-October/004787.html

Anyway, Ohtake should have received the review. The driver is *not* yet
ready for inclusion. Therefore, please fix the remaining issues asap.

Thanks,

Wolfgang.
