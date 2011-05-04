From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] can: make struct can_proto const
Date: Wed, 04 May 2011 14:08:48 -0700 (PDT)
Message-ID: <20110504.140848.15229373.davem@davemloft.net>
References: <20110504044057.GC278@e-circ.dyndns.org>
	<4DC1B86A.40308@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DC1B86A.40308-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Date: Wed, 04 May 2011 22:34:50 +0200

> On 04.05.2011 06:40, Kurt Van Dijck wrote:
>> commit 53914b67993c724cec585863755c9ebc8446e83b had the
>> same message. That commit did put everything in place but
>> did not make can_proto const itself.
>> 
>> Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
>> 
> 
> Acked-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

Applied.
