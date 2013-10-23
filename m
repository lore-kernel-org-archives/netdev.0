From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v5 0/5] xen-netback: IPv6 offload support
Date: Wed, 23 Oct 2013 13:30:42 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD013F6AC@AMSPEX01CL01.citrite.net>
References: <1381942232-26268-1-git-send-email-paul.durrant@citrix.com>
 <20131017.153622.88986190427961174.davem@davemloft.net>
 <20131023123955.GA17440@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15229 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456Ab3JWNcg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 09:32:36 -0400
In-Reply-To: <20131023123955.GA17440@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 23 October 2013 13:40
> To: David Miller
> Cc: Paul Durrant; xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu
> Subject: Re: [PATCH net-next v5 0/5] xen-netback: IPv6 offload support
> 
> On Thu, Oct 17, 2013 at 03:36:22PM -0400, David Miller wrote:
> > From: Paul Durrant <paul.durrant@citrix.com>
> > Date: Wed, 16 Oct 2013 17:50:27 +0100
> >
> > > This patch series adds support for checksum and large packet offloads
> into
> > > xen-netback.
> > > Testing has mainly been done using the Microsoft network hardware
> > > certification suite running in Server 2008R2 VMs with Citrix PV frontends.
> >
> > Series applied, thanks.
> 
> Paul, now that this series is applied to net-next, could you send a
> patch to Xen's master copy netif.h?
> 

Will do. Thanks for the reminder.

  Paul
