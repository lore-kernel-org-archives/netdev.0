From: Amit Kale <amitkale@netxen.com>
Subject: Re: [PATCH 0/5] NetXen: Driver bug fixes
Date: Mon, 12 Mar 2007 11:46:31 +0530
Message-ID: <200703121146.31531.amitkale@netxen.com>
References: <200703090805.l29855n5011673@dut39.unminc.com> <200703101239.16417.amitkale@netxen.com> <45F294DC.50300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>,
	netdev@vger.kernel.org, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:16072 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965143AbXCLGQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 02:16:08 -0400
In-Reply-To: <45F294DC.50300@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 March 2007 16:52, Jeff Garzik wrote:
> Amit Kale wrote:
> > On Friday 09 March 2007 22:26, Jeff Garzik wrote:
> >> Linsys Contractor Mithlesh Thukral wrote:
> >>> Hi All,
> >>>
> >>> I will be sending updates to NetXen: 1G/10G Ethernet driver in
> >>> subsequent mails. The patches will be with respect to netdev#upstream.
> >>
> >> Are you sure you don't want some of these in #upstream-fixes, queued for
> >> 2.6.21-rc?
> >
> > We really want them in both places. If we send them to #upstream-fixes,
> > they'll break #upstream. Should we send them against both of these
> > branches?
>
> Well, I can drop NetXen patches in #upstream, apply these to
> #upstream-fixes, and wait for a resend?

Could you do that, please? (drop NetXen patches in #upstream)

We'll resend them against #upstream-fixes.
Thanks.
-Amit
