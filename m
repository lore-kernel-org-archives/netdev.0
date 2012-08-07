From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Tue, 07 Aug 2012 10:27:01 +0800
Message-ID: <1344306421.6917.0.camel@cr0>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	 <1344263012-4031-8-git-send-email-amwang@redhat.com>
	 <20120806.135003.442648448779232464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932552Ab2HGC1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 22:27:09 -0400
In-Reply-To: <20120806.135003.442648448779232464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 13:50 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Mon,  6 Aug 2012 22:23:31 +0800
> 
> > +	/*
> > +	 * We don't notify NETDEV_RELEASE event, as this will
> > +	 * stop netconsole on the bridge.
> > +	 */
> 
> Please format comments in the networking:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> Thanks.

Ok, I will update and resend this single patch. :)
