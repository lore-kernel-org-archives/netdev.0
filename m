From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next V7 0/4] Bundle fixes for Xen netfront / netback
Date: Mon, 22 Apr 2013 20:53:35 +0100
Message-ID: <20130422195335.GA30755@zion.uk.xensource.com>
References: <1366633243-17775-1-git-send-email-wei.liu2@citrix.com>
 <20130422.154139.1046488577191797292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43538 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755081Ab3DVTxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:53:37 -0400
Content-Disposition: inline
In-Reply-To: <20130422.154139.1046488577191797292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 08:41:39PM +0100, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Mon, 22 Apr 2013 13:20:39 +0100
> 
> > This series is now rebased onto net-next.
> > 
> > We would also like to ask you to queue it for stable-ish tree. I can do the
> > backport if necessary.
> 
> All applied, but this was a disaster.
> 

Thanks, I misunderstood the workflow.

> If you want bug fixes propagated into -stable you submit them to 'net'
> from the beginning.
> 
> There is no other method by which to do this.
> 
> By merging all of these changes to net-next, you will now have to get
> them accepted again into 'net', and then (and only then) can you make
> a request for -stable inclusion.
> 

Understood. Will submit them against 'net' later.

> You are making so much extra work for me, please don't do this ever
> again.
> 

Sorry for this.


Wei.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
