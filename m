From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] NetXen: Driver bug fixes
Date: Sat, 10 Mar 2007 06:22:04 -0500
Message-ID: <45F294DC.50300@garzik.org>
References: <200703090805.l29855n5011673@dut39.unminc.com> <45F191B3.8090609@garzik.org> <200703101239.16417.amitkale@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>,
	netdev@vger.kernel.org, netxenproj@linsyssoft.com, rob@netxen.com
To: Amit Kale <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36089 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbXCJLWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2007 06:22:09 -0500
In-Reply-To: <200703101239.16417.amitkale@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit Kale wrote:
> On Friday 09 March 2007 22:26, Jeff Garzik wrote:
>> Linsys Contractor Mithlesh Thukral wrote:
>>> Hi All,
>>>
>>> I will be sending updates to NetXen: 1G/10G Ethernet driver in subsequent
>>> mails. The patches will be with respect to netdev#upstream.
>> Are you sure you don't want some of these in #upstream-fixes, queued for
>> 2.6.21-rc?
> 
> We really want them in both places. If we send them to #upstream-fixes, 
> they'll break #upstream. Should we send them against both of these branches?

Well, I can drop NetXen patches in #upstream, apply these to 
#upstream-fixes, and wait for a resend?
