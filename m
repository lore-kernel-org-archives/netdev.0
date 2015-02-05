From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] hyperv: fix sparse warnings
Date: Thu, 5 Feb 2015 17:04:21 +0000
Message-ID: <BN1PR0301MB07701B2222A5CFA1BB2D55BFCA3B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1423148793-19610-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>,
	KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423148793-19610-1-git-send-email-prabhakar.csengg@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Lad Prabhakar [mailto:prabhakar.csengg@gmail.com]
> Sent: Thursday, February 5, 2015 10:07 AM
> To: KY Srinivasan; Haiyang Zhang; devel@linuxdriverproject.org
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Lad, Prabhakar
> Subject: [PATCH] hyperv: fix sparse warnings
> 
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warnings:
> 
> netvsc.c:688:5: warning: symbol 'netvsc_copy_to_send_buf' was not
> declared. Should it be static?
> rndis_filter.c:627:5: warning: symbol 'rndis_filter_set_offload_params'
> was not declared. Should it be static?
> rndis_filter.c:702:5: warning: symbol 'rndis_filter_set_rss_param' was
> not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Thanks.
