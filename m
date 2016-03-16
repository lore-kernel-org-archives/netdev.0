From: Dexuan Cui <decui@microsoft.com>
Subject: RE: When will net-next merge with linux-next?
Date: Wed, 16 Mar 2016 01:58:50 +0000
Message-ID: <BLUPR03MB14104FD16924FB8327BD9AA8BF8A0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160314162139.GA2925@kroah.com>
 <BLUPR03MB141045D7EED478CB0A086CA1BF890@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160315150534.GB12990@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0115.outbound.protection.outlook.com ([65.55.169.115]:56160
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751033AbcCPB6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 21:58:55 -0400
In-Reply-To: <20160315150534.GB12990@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> Sent: Tuesday, March 15, 2016 23:06
> To: Dexuan Cui <decui@microsoft.com>
> Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
> Subject: Re: When will net-next merge with linux-next?
> 
> On Tue, Mar 15, 2016 at 11:11:34AM +0000, Dexuan Cui wrote:
> > I'm wondering whether (and when) step 2 will happen in the next 2 weeks,
> > that is, before the tag 4.6-rc1 is made.
> > If not, I guess I'll miss 4.6?
> 
> You missed 4.6 as your patch was not in any of our trees a few days
> before 4.5 was released, sorry.
> 
> greg k-h
Hi Greg,
Thanks for the reply!

My patch has to go in net-next first, but even today's mainline and net-next
haven't had the supporting patches in the VMBus driver, so I can't post my
patch to net-next even today  -- it seems it's doomed to need 2 major
release cycles to push a feature that makes changes to 2 subsystems? :-(

I guess Greg will send a pull request to Linus within the next 1~2 weeks, so
the supporting VMBus patches will be in the mainline after that.

Hi David,
May I know when you'll merge with the mainline kernel and how
frequently do you usually do it?

Thanks,
-- Dexuan
