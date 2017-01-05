From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net] hyper-v: Add myself as additional MAINTAINER
Date: Thu, 5 Jan 2017 21:09:11 +0100
Message-ID: <20170105200911.GA6579@kroah.com>
References: <20170105173626.4657-1-sthemmin@microsoft.com>
 <DM5PR03MB24904C998F63FDF80C4CBB16A0600@DM5PR03MB2490.namprd03.prod.outlook.com>
 <20170105182911.GA16146@kroah.com>
 <DM5PR03MB24902386946C55BCE617941CA0600@DM5PR03MB2490.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39266 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032737AbdAEUJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:09:28 -0500
Content-Disposition: inline
In-Reply-To: <DM5PR03MB24902386946C55BCE617941CA0600@DM5PR03MB2490.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2017 at 07:08:23PM +0000, KY Srinivasan wrote:
> 
> 
> > -----Original Message-----
> > From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> > Sent: Thursday, January 5, 2017 10:29 AM
> > To: KY Srinivasan <kys@microsoft.com>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>;
> > davem@davemloft.net; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; Stephen Hemminger <sthemmin@microsoft.com>
> > Subject: Re: [PATCH net] hyper-v: Add myself as additional MAINTAINER
> > 
> > On Thu, Jan 05, 2017 at 05:43:04PM +0000, KY Srinivasan wrote:
> > >
> > >
> > > > -----Original Message-----
> > > > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > > > Sent: Thursday, January 5, 2017 9:36 AM
> > > > To: davem@davemloft.net; KY Srinivasan <kys@microsoft.com>
> > > > Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> > > > gregkh@linuxfoundation.org; Stephen Hemminger
> > > > <sthemmin@microsoft.com>
> > > > Subject: [PATCH net] hyper-v: Add myself as additional MAINTAINER
> > > >
> > > > Update the Hyper-V MAINTAINERS to include myself.
> > > >
> > > > Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> > >
> > > Acked-by: K. Y. Srinivasan <kys@microsoft.com>
> > 
> > Thanks, will go queue this up now.
> 
> Thanks Greg. On a different note, there are a bunch of Hyper-V specific
> patches that have been submitted over the last month or so that have not
> been committed. Should I resend them.

Nope, they are still in my mbox, I'm just going through stuff that has
to be in 4.10-final at the moment, give me another week or so to catch
up on all the new stuff for 4.11-rc1.

thanks,

greg k-h
