From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] s2io: add dynamic LRO disable support
Date: Fri, 25 Jun 2010 17:09:02 +0800
Message-ID: <4C24722E.9080105@redhat.com>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain> <20100625044510.GC2739@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab0FYJFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 05:05:00 -0400
In-Reply-To: <20100625044510.GC2739@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/10 12:45, Jon Mason wrote:
> This patch adds dynamic LRO disable support for s2io net driver,
> enables LRO by default, increases the driver version number, and
> corrects the name of the LRO modparm.
>

Very good work, Jon! I believe this version is the best we have.

Thanks again!
