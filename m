From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 03/11] net/can: use printk_ratelimited() instead of
	printk_ratelimit()
Date: Fri, 17 Jun 2011 00:03:23 -0400 (EDT)
Message-ID: <20110617.000323.333992491144793487.davem@davemloft.net>
References: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
	<6c8d043e92e68ab304999fc1a1f7f4c7a04a818e.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	christian.dietrich-jNDFPZUTrfT6U6xlzOR6HsSSVFg4/55HhC4ANOJQIlc@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: manuel.f.zerpies-BvGhN7WtUVpvnyFi9AzMs1NpE/a5I+DW@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <6c8d043e92e68ab304999fc1a1f7f4c7a04a818e.1308142053.git.manuel.f.zerpies-BvGhN7WtUVpvnyFi9AzMs1NpE/a5I+DW@public.gmane.org>
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

From: Manuel Zerpies <manuel.f.zerpies-BvGhN7WtUVpvnyFi9AzMs1NpE/a5I+DW@public.gmane.org>
Date: Thu, 16 Jun 2011 14:08:01 +0200

> Since printk_ratelimit() shouldn't be used anymore (see comment in
> include/linux/printk.h), replace it with printk_ratelimited().
> 
> Signed-off-by: Manuel Zerpies <manuel.f.zerpies-BvGhN7WtUVpvnyFi9AzMs1NpE/a5I+DW@public.gmane.org>

Applied.
