From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: When will net-next merge with linux-next?
Date: Tue, 15 Mar 2016 19:40:58 -0700
Message-ID: <20160316024058.GA29922@kroah.com>
References: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160314162139.GA2925@kroah.com>
 <BLUPR03MB141045D7EED478CB0A086CA1BF890@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160315150534.GB12990@kroah.com>
 <BLUPR03MB14104FD16924FB8327BD9AA8BF8A0@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:43638 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbcCPClA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 22:41:00 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR03MB14104FD16924FB8327BD9AA8BF8A0@BLUPR03MB1410.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 01:58:50AM +0000, Dexuan Cui wrote:
> > From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> > Sent: Tuesday, March 15, 2016 23:06
> > To: Dexuan Cui <decui@microsoft.com>
> > Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org; KY
> > Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
> > Subject: Re: When will net-next merge with linux-next?
> > 
> > On Tue, Mar 15, 2016 at 11:11:34AM +0000, Dexuan Cui wrote:
> > > I'm wondering whether (and when) step 2 will happen in the next 2 weeks,
> > > that is, before the tag 4.6-rc1 is made.
> > > If not, I guess I'll miss 4.6?
> > 
> > You missed 4.6 as your patch was not in any of our trees a few days
> > before 4.5 was released, sorry.
> > 
> > greg k-h
> Hi Greg,
> Thanks for the reply!
> 
> My patch has to go in net-next first, but even today's mainline and net-next
> haven't had the supporting patches in the VMBus driver, so I can't post my
> patch to net-next even today  -- it seems it's doomed to need 2 major
> release cycles to push a feature that makes changes to 2 subsystems? :-(

Usually, yes, unless you talk to us ahead of time so we can coordinate,
or have one of the patches go through a different tree (i.e. all in one
tree.).

Just wait until 4.6-rc1 is out and all will be fine.

greg k-h
