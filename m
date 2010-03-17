From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Uclinux-dist-devel] [PATCH] can: bfin_can: switch to common
	Blackfin can header
Date: Tue, 16 Mar 2010 22:02:32 -0700 (PDT)
Message-ID: <20100316.220232.170244945.davem@davemloft.net>
References: <1268150589-27123-1-git-send-email-vapier@gentoo.org>
	<20100316.212830.50212878.davem@davemloft.net>
	<8bd0f97a1003162145i77f65158ne255b28239e1b595@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8bd0f97a1003162145i77f65158ne255b28239e1b595-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 17 Mar 2010 00:45:06 -0400

> On Wed, Mar 17, 2010 at 00:28, David Miller wrote:
>> From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
>> Date: Tue, =A09 Mar 2010 11:03:09 -0500
>>
>>> The MMR bits are being moved to this header, so include it.
>>>
>>> Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
>>
>> I can't actually apply this since this asm/bfin_can.h header
>> doesn't even exist in the tree yet so this change will
>> break the build.
> =

> Linus was supposed to pull my tree, but if that isnt going to happen
> for 2.6.34, then just apply the patch for 2.6.35

That's what I was going to do, apply it to net-next-2.6
but I can't even do that until the asm/bfin_can.h change
appears in Linus's tree.
