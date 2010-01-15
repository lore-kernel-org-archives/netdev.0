From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: mscan-mpc5xxx: fix broken support
	for the MPC5200
Date: Fri, 15 Jan 2010 01:44:08 -0800 (PST)
Message-ID: <20100115.014408.40775945.davem@davemloft.net>
References: <4B4EFA8C.4010209@grandegger.com>
	<20100114111524.GA6041@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100114111524.GA6041-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date: Thu, 14 Jan 2010 12:15:24 +0100

> On Thu, Jan 14, 2010 at 12:05:48PM +0100, Wolfgang Grandegger wrote:
>> From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
>> 
>> Due to an invalid "#ifdef CONFIG_PPC_MPC5200", the real clock setup
>> function was not called for the MPC5200.
>> 
>> Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
> 
> Acked-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Applied, thanks.
