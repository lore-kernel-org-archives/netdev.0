From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/5] net/hyperv: Convert camel cased variables in
 rndis_filter.c to lower cases
Date: Wed, 1 Feb 2012 19:39:21 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0CD2192F@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
 <20120201.143655.1013171439305457146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120201.143655.1013171439305457146.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 01, 2012 2:37 PM
> To: Haiyang Zhang
> Cc: KY Srinivasan; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 1/5] net/hyperv: Convert camel cased variables in
> rndis_filter.c to lower cases
> 
> 
> Please do not mix cleanups with real bug fixes.
> 
> Patches #4 and #5 in this series fix real bugs, so you should submit them
> seperately for inclusion to my 'net' tree.
> 
> Once those fixes have propagated to my 'net-next' tree, you can then
> submit
> the cleanups.

Will do.

Thanks,
- Haiyang
