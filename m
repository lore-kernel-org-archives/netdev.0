From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.43 0/5] MPLS actions and matches
Date: Wed, 16 Oct 2013 13:47:43 -0700
Message-ID: <20131016204743.GB4526@nicira.com>
References: <1381132847-12589-1-git-send-email-horms@verge.net.au>
 <20131010003139.GA20311@verge.net.au>
 <20131016035530.GA29165@nicira.com>
 <CAEP_g=-yCas_3MRY0VrP-W6hOi4wRYNW7=8HEB0GYOp--WU60A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:43088 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1761334Ab3JPUrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 16:47:49 -0400
Received: by mail-qa0-f47.google.com with SMTP id k15so4658090qaq.6
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 13:47:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAEP_g=-yCas_3MRY0VrP-W6hOi4wRYNW7=8HEB0GYOp--WU60A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 01:21:22PM -0700, Jesse Gross wrote:
> On Tue, Oct 15, 2013 at 8:55 PM, Ben Pfaff <blp@nicira.com> wrote:
> > On Thu, Oct 10, 2013 at 09:31:41AM +0900, Simon Horman wrote:
> >> I believe this series addresses the feedback that each of you
> >> gave with regards to recent previous postings of this patch-set.
> >> I'm wondering if you could find some time to review it.
> >
> > I'm waiting for an ack from Jesse, then I'm going to do a final pass and
> > I hope to commit this series at this point.  I see some ways that we can
> > improve MPLS support afterward but I don't see any blockers.
> 
> I guess that we had a deadlock as I was waiting for you. I though that
> maybe you would commit the rest of the userspace patches and then I
> would just pick up the last two.

Ah, OK.

I will do this, then, after a final pass.
