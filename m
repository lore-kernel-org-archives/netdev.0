From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Tue, 17 Sep 2013 17:05:39 -0700
Message-ID: <20130918000539.GF13848@nicira.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
 <20130916204619.GE20037@nicira.com>
 <20130917234717.GA3675@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:44887 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752890Ab3IRAFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 20:05:47 -0400
Received: by mail-ve0-f178.google.com with SMTP id jw12so4867844veb.37
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 17:05:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130917234717.GA3675@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 06:47:22PM -0500, Simon Horman wrote:
> On Mon, Sep 16, 2013 at 01:46:19PM -0700, Ben Pfaff wrote:
> > On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
> > >  - Ben, do you want to take over for the userspace portions of the
> > > series on the assumption that the above comments can be fixed fairly
> > > easily?
> > 
> > Yes, that's fine.  Simon, I guess that you are looking at Jesse's
> > comments about mpls_depth from earlier?
> 
> Yes, I have a solution to that problem and I will post it after testing
> further. I don't think it will affect the other user-space patches
> in a material way. So I think you can review them as-is.

That sounds good, thanks.
