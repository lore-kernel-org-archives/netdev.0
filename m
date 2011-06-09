From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: Request for review on Hyper-V virtual network driver
Date: Thu, 9 Jun 2011 22:16:41 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC09603EE8@TK5EX14MBXC227.redmond.corp.microsoft.com>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
 <1307655530.13329.49.camel@Joe-Laptop>
 <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
 <20110609220701.GA24006@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Joe Perches <joe@perches.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	"KY Srinivasan" <kys@microsoft.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailc.microsoft.com ([131.107.115.214]:34267 "EHLO
	smtp.microsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755335Ab1FIWQm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 18:16:42 -0400
In-Reply-To: <20110609220701.GA24006@suse.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Greg KH [mailto:gregkh@suse.de]
> Sent: Thursday, June 09, 2011 6:07 PM
> > > I suggest you resend this using the -M or --find-renames option.
> >
> > Will do.
> 
> No, that will not show anything at all, which is the point of the
> review.  Otherwise it will just require someone to go look at the
> drivers/staging/hv/ directory in linux-next to properly determine what
> is happening here.
> 
> So this patch is fine for a review.

OK, so I will wait for further review comments on the netvsc files.

Thanks,
- Haiyang
