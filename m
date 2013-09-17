From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCHv2 net] xen-netback: count number required slots for an
 skb more carefully
Date: Tue, 17 Sep 2013 15:05:27 +0100
Message-ID: <1379426727.11304.103.camel@hastur.hellion.org.uk>
References: <1378907568-8062-1-git-send-email-david.vrabel@citrix.com>
	 <20130912.232328.1199260755421139102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <david.vrabel@citrix.com>, <xen-devel@lists.xen.org>,
	<konrad.wilk@oracle.com>, <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22424 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270Ab3IQOFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 10:05:41 -0400
In-Reply-To: <20130912.232328.1199260755421139102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 23:23 -0400, David Miller wrote:
> I assume you want this queued up for -stable,

I think so, David V -- do you know how far back this goes?

>  and can you check if
> there is any non-trivial backporting for earlier kernels?

Another one I hope David can answer...

Ian.
