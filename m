From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH v3] hyperv: Add netpoll support
Date: Wed, 9 Jul 2014 18:08:51 +0000
Message-ID: <1773ae9702234a1d9e86ccf343c68c21@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1404915839-15940-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>,
	KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404915839-15940-1-git-send-email-richard@nod.at>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Richard Weinberger [mailto:richard@nod.at]
> Sent: Wednesday, July 9, 2014 10:24 AM
> To: KY Srinivasan; Haiyang Zhang
> Cc: sergei.shtylyov@cogentembedded.com; romieu@fr.zoreil.com;
> devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Richard Weinberger
> Subject: [PATCH v3] hyperv: Add netpoll support
> 
> In order to have at least a netconsole to debug kernel issues on
> Windows Azure this patch implements netpoll support.
> Sending packets is easy, netvsc_start_xmit() does already everything
> needed.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>
Acked-by: Haiyang Zhang <haiyangz@microsoft.com>

Thanks.
