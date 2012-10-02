From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net,1/3] hyperv: Fix the max_xfer_size in RNDIS
 initialization
Date: Tue, 2 Oct 2012 02:07:44 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DE315E5@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1349130657-7987-1-git-send-email-haiyangz@microsoft.com>,<20121001.183919.1364005468105446885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:46544
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752533Ab2JBCHz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 22:07:55 -0400
In-Reply-To: <20121001.183919.1364005468105446885.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
> From: David Miller [davem@davemloft.net]
> Sent: Monday, October 01, 2012 6:39 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com; linux-kernel@vger.kernel.org; devel@linuxdriverproject.org
> Subject: Re: [PATCH net,1/3] hyperv: Fix the max_xfer_size in RNDIS initialization

> These patches do not apply cleanly to the current net-next tree
> which is the only place where patches should be targetted right
> now.

I will rebase the patch set to the net-next tree soon.

Thanks,
- Haiyang
