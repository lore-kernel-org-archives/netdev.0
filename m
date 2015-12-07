From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 0/2] net: thunderx: Miscellaneous cleanups
Date: Mon, 07 Dec 2015 13:33:55 +0300
Message-ID: <014f01d130da$c72c2d60$55848820$@samsung.com>
References: <y@samsung.com>
 <1449464433-43343-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Sunil Goutham' <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1449464433-43343-1-git-send-email-sunil.kovvuri@gmail.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Tested-by: Pavel Fedin <p.fedin@samsung.com>

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Sunil
> Goutham
> Sent: Monday, December 07, 2015 8:01 AM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org; p.fedin@samsung.com;
> Sunil.Goutham@caviumnetworks.com; Sunil Goutham
> Subject: [PATCH 0/2] net: thunderx: Miscellaneous cleanups
> 
> From: Sunil Goutham <sgoutham@cavium.com>
> 
> This patch series contains contains couple of cleanup patches.
> 
> Sunil Goutham (1):
>   net, thunderx: Remove unnecessary rcv buffer start address management
> 
> Yury Norov (1):
>   net: thunderx: nicvf_queues: nivc_*_intr: remove duplication
> 
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  189 +++++---------------
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   10 +-
>  2 files changed, 51 insertions(+), 148 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
