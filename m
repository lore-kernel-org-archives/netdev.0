From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Tue, 17 Sep 2013 18:47:22 -0500
Message-ID: <20130917234717.GA3675@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
 <20130916204619.GE20037@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48052 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab3IQXrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 19:47:42 -0400
Content-Disposition: inline
In-Reply-To: <20130916204619.GE20037@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 01:46:19PM -0700, Ben Pfaff wrote:
> On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
> >  - Ben, do you want to take over for the userspace portions of the
> > series on the assumption that the above comments can be fixed fairly
> > easily?
> 
> Yes, that's fine.  Simon, I guess that you are looking at Jesse's
> comments about mpls_depth from earlier?

Yes, I have a solution to that problem and I will post it after testing
further. I don't think it will affect the other user-space patches
in a material way. So I think you can review them as-is.
