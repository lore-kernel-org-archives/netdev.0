From: wg <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: wrong index used in inner loop
Date: Tue, 15 Mar 2011 10:02:25 +0100
Message-ID: <edb90b03bb533480b6a5cea0e0c0822d@grandegger.com>
References: <4D768917.9040605@gmail.com>
	<20110314.144743.232749141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110314.144743.232749141.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Mon, 14 Mar 2011 14:47:43 -0700 (PDT), David Miller
<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: roel <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 08 Mar 2011 20:52:55 +0100
> 
>> Index i was already used in the outer loop.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> CAN maintainers, could you please review and ACK patches in a timely
> manner,
> especially utterly trivial bug fixes like this one here?
> 
> That's largely what I've been waiting for, a simple sign of life from
the
> listed maintainers for these files.

OK, will try to react fast next time.

> Anyways, no use waiting any longer, applied, thanks Roel.

Thanks,

Wolfgang.
