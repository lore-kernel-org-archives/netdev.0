From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Uclinux-dist-devel] [PATCH] can: bfin_can: switch to common
	Blackfin can header
Date: Tue, 16 Mar 2010 22:51:50 -0700 (PDT)
Message-ID: <20100316.225150.213941689.davem@davemloft.net>
References: <8bd0f97a1003162145i77f65158ne255b28239e1b595@mail.gmail.com>
	<20100316.220232.170244945.davem@davemloft.net>
	<8bd0f97a1003162225i439d9900mfdc03eca5de0ff6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8bd0f97a1003162225i439d9900mfdc03eca5de0ff6e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Date: Wed, 17 Mar 2010 01:25:39 -0400

> if the next tree is merged into linux-next, then the header is already there

One of the highest priority trees in -next is net-next-2.6,
because so much other stuff ends up depending upon it.

Therefore I keep it building independently, so no matter what Stephen
Rothwell does the build isn't likely to break.

Just get your stuff merged properly to Linus then resubmit
your patch.

Else, resubmit with the header addition included.

Your choice :-)
