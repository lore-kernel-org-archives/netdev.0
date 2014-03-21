From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v4] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Fri, 21 Mar 2014 19:42:21 +0000
Message-ID: <58b32963c3b7416b82e96267d42b926f@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <20140321.144957.550032279989990583.davem@davemloft.net>
	<20140321.145501.2003616654661701935.davem@davemloft.net>
	<84837c9e73f24bcd8f652a24f616ff1e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140321.153237.2236797908349183626.davem@davemloft.net>
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
In-Reply-To: <20140321.153237.2236797908349183626.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, March 21, 2014 3:33 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v4] hyperv: Add support for virtual Receive
> Side Scaling (vRSS)
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Fri, 21 Mar 2014 19:12:43 +0000
> 
> > Could it be merged into net-next tree?
> 
> You submitted a patch against net-next, that means you are implicitly
> stating that all dependencies are in place in _that_ tree and that
> you tested it in _that_ tree.
> 
> If the situation is otherwise you must explicitly state this in your
> patch submission.

I will re-submit the vRSS patch with the dependency specified.
Thanks,
- Haiyang
