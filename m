From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on RealView
Date: Tue, 4 Nov 2008 22:16:38 +0000
Message-ID: <OF0DAADA4B.C8BB0F5E-ON802574F7.007A3B07-802574F7.007A6C26@smsc.com>
References: <4910AFBB.6080506@billgatliff.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Ian.Saturley@smsc.com, jeff@garzik.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org
To: Bill Gatliff <bgat@billgatliff.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1676 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754197AbYKDWRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 17:17:48 -0500
In-Reply-To: <4910AFBB.6080506@billgatliff.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bill,

Yes, I'm working now on a patchset to move all the in-tree users over. 
I'll post it for review/testing once it's complete.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com



Bill Gatliff <bgat@billgatliff.com> wrote on 04/11/2008 20:25:31:

> Steve.Glendinning@smsc.com wrote:
> > Hi Jeff,
> > 
> > Russell's was the last response on this subject, so I guess there are 
no 
> > strong objections?
> > 
> > If I add the missing features (to bring the smsc911x driver up to 
feature 
> > parity with smc911x) before the next merge window, would you accept a 
> > patchset to add it and deprecate the existing driver?
> 
> By "deprecate" you mean "switch users over to the new driver"?
> 
> 
> b.g.
> -- 
> Bill Gatliff
> bgat@billgatliff.com

