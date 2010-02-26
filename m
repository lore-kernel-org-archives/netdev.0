From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3] can: ti hecc module : add platform specific
	initialization callback.
Date: Fri, 26 Feb 2010 05:22:23 -0800 (PST)
Message-ID: <20100226.052223.192373841.davem@davemloft.net>
References: <1267190078-22328-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: srk-l0cyMroinI0@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1267190078-22328-1-git-send-email-srk-l0cyMroinI0@public.gmane.org>
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

From: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Date: Fri, 26 Feb 2010 18:44:38 +0530

> CAN module on AM3517 requires programming of IO expander as part
> of init sequence - to enable CAN PHY. Added platform specific
> callback to handle phy control(switch on /off).
> 
> Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>

Applied, thanks.
