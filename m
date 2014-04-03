From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v4] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Thu, 3 Apr 2014 15:17:28 +0000
Message-ID: <aa48898a5b084977b7b9ef8aa1588a43@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1396541134-9588-1-git-send-email-haiyangz@microsoft.com>
 <20140403.111508.1416100875090509051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140403.111508.1416100875090509051.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 3, 2014 11:15 AM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v4] hyperv: Add support for virtual Receive Side
> Scaling (vRSS)
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Thu,  3 Apr 2014 09:05:34 -0700
> 
> > This feature allows multiple channels to be used by each virtual NIC.
> > It is available on Hyper-V host 2012 R2.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> I announced on netdev the other day that the merge window is open and I'm
> not accepting patches for new features until the net-next tree is open again.

I see. (I found the dependency was merged in, so I was re-submitting... )
I will wait for the net-next tree opening.

Thanks,
- Haiyang
