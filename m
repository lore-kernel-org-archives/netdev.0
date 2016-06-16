From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCHv4 net-next 05/12] ndisc: add __ndisc_opt_addr_data
 function
Date: Thu, 16 Jun 2016 12:44:32 +0200
Message-ID: <99766fd7-dd4e-9dbb-e706-ef38209109cc@stressinduktion.org>
References: <20160615192027.4064-1-aar@pengutronix.de>
 <20160615192027.4064-6-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160615192027.4064-6-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15.06.2016 21:20, Alexander Aring wrote:
> This patch adds __ndisc_opt_addr_data as low-level function for
> ndisc_opt_addr_data which doesn't depend on net_device parameter.
> 
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Acked-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
