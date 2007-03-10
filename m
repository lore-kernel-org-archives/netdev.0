From: Amit Kale <amitkale@netxen.com>
Subject: Re: [PATCH 0/5] NetXen: Driver bug fixes
Date: Sat, 10 Mar 2007 12:39:16 +0530
Message-ID: <200703101239.16417.amitkale@netxen.com>
References: <200703090805.l29855n5011673@dut39.unminc.com> <45F191B3.8090609@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>,
	netdev@vger.kernel.org, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:14604 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932869AbXCJHIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 02:08:53 -0500
In-Reply-To: <45F191B3.8090609@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 March 2007 22:26, Jeff Garzik wrote:
> Linsys Contractor Mithlesh Thukral wrote:
> > Hi All,
> >
> > I will be sending updates to NetXen: 1G/10G Ethernet driver in subsequent
> > mails. The patches will be with respect to netdev#upstream.
>
> Are you sure you don't want some of these in #upstream-fixes, queued for
> 2.6.21-rc?

We really want them in both places. If we send them to #upstream-fixes, 
they'll break #upstream. Should we send them against both of these branches?

Pardon for this newbie question :-).

Thanks.
-Amit
