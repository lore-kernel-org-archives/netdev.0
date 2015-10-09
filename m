From: Yaowei Bai <bywxiaobai@163.com>
Subject: Re: [PATCH 4/9] net/can: can_dropped_invalid_skb can be boolean
Date: Fri, 9 Oct 2015 22:25:02 +0800
Message-ID: <20151009142502.GA5427@bbox>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
 <1444310942-4428-5-git-send-email-bywxiaobai@163.com>
 <56179387.1090301@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56179387.1090301@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2015 at 12:14:31PM +0200, Marc Kleine-Budde wrote:
> On 10/08/2015 03:28 PM, Yaowei Bai wrote:
> > This patch makes can_dropped_invalid_skb return bool due to this
> > particular function only using either one or zero as its return
> > value.
> > 
> > No functional change.
> > 
> > Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Thanks.

> 
> Yaowei, feel free to send the CAN patch as part of your series directly
> to David.

OK, i'll do that and sorry for disturbing you. :)

Thanks
Bai

> 
> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 
