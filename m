From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [Uclinux-dist-devel] [PATCH] SMSC LAN911x and LAN921x vendor
	driver
Date: Mon, 19 May 2008 16:55:23 +0100
Message-ID: <1211212523.24946.34.camel@pc1117.cambridge.arm.com>
References: <20080515170728.GA3176@PTXN0038.genpitfi01.og.ge.com>
	 <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
	 <8bd0f97a0805190827qe5ae0a3r44c2067be76f41d9@mail.gmail.com>
	 <1211211904.24946.30.camel@pc1117.cambridge.arm.com>
	 <8bd0f97a0805190850g38d6ca85gd1f72fef20c6ce66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	Michael.Hennerich@analog.com, Bill Gatliff <bgat@billgatliff.com>,
	netdev@vger.kernel.org, ian.saturley@smsc.com,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:40171 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752013AbYESPyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 11:54:43 -0400
In-Reply-To: <8bd0f97a0805190850g38d6ca85gd1f72fef20c6ce66@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-19 at 11:50 -0400, Mike Frysinger wrote:
> On Mon, May 19, 2008 at 11:45 AM, Catalin Marinas wrote:
> > On Mon, 2008-05-19 at 11:27 -0400, Mike Frysinger wrote:
> >> i thought we were against this sort of changelog stuff in files.  let
> >> the scm take care of the changelog.
> >
> > I don't have a strong opinion on whether the changelog in the file
> > should be kept or not and I won't argue. However, in this particular
> > instance there is no SCM log since the driver is not merged into the
> > mainline kernel. When/if it is merged, this will happen as a patch
> > without an SCM log.
> 
> while all true, the problem is that people who make updates in the
> future often times will also update the in-file changelog
> 
> you could move the changelog out of the file and into the first commit
> message

You are right, that seems even better. Thanks.

-- 
Catalin

