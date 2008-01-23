From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] [IrDA] LMP discovery timer not started by
	default
Date: Tue, 22 Jan 2008 18:28:30 -0800 (PST)
Message-ID: <20080122.182830.35711427.davem@davemloft.net>
References: <20080123033422.GA20754@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ross-RWuK6r/cQWRpLGFMi4vTTA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20080123033422.GA20754-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Date: Wed, 23 Jan 2008 04:34:22 +0100

> By default, LMP sets up a 3 seconds timer for discovery.
> We don't need it until discovery is set to 1.
> 
> This patch is against your latest net-2.6.25 tree.
> 
> From: Ross Burton <ross-RWuK6r/cQWRpLGFMi4vTTA@public.gmane.org>
> Signed-off-by: Ross Burton <ross-RWuK6r/cQWRpLGFMi4vTTA@public.gmane.org>
> Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

Applied, thanks Sam.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
