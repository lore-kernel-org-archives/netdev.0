From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] Add hash value into RNDIS Per-packet info
Date: Fri, 23 May 2014 18:52:29 +0000
Message-ID: <c70268824a95436aab3e3e8c0bbf4201@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1400702139-29280-1-git-send-email-haiyangz@microsoft.com>
 <20140523.145001.2140056621716323006.davem@davemloft.net>
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
In-Reply-To: <20140523.145001.2140056621716323006.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, May 23, 2014 2:50 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] Add hash value into RNDIS Per-packet info
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Wed, 21 May 2014 12:55:39 -0700
> 
> > It passes the hash value as the RNDIS Per-packet info to the Hyper-V
> host,
> > so that the send completion notices can be spread across multiple
> channels.
> > MS-TFS: 140273
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> 
> Applied, but please craft your Subject lines correctly in the future.
> 
> You did not specify a subsystem prefix, which in this case should
> have been something like "hyperv: "
> 
> Otherwise people scanning the commit log headers have no idea where
> your changes might be taking place.
> 
> I fixed it up this time for you.

Thank you for fixing it! I will do this in the future.

Thanks,
- Haiyang
