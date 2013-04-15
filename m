From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V4 7/7] xen-netback: don't disconnect frontend when
 seeing oversize packet
Date: Mon, 15 Apr 2013 16:22:24 +0100
Message-ID: <20130415152224.GH17602@zion.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
 <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
 <CAJ75kXb1Pc83sAjqDuzeGiikTcqdqrgPTxTT7kS-agUqoZp7LA@mail.gmail.com>
 <1366016605.4963.6.camel@zakaz.uk.xensource.com>
 <20130415145320.GE17602@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: William Dauchy <wdauchy@gmail.com>, Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20355 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814Ab3DOPW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 11:22:26 -0400
Content-Disposition: inline
In-Reply-To: <20130415145320.GE17602@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 03:53:20PM +0100, Wei Liu wrote:
> 
> 5-7 are the real meat. If 1-4 are not taken to stable, they will need
> small adjustment to apply, which is just trivial.
> 

And just to be clear, 5 is not specific written for XSA-39 as it is a
fix for netfront and XSA-39 is fix to netback. However it should
go to stable as well.


Wei.

> 
> Wei.
> 
> > Ian.
> > 
