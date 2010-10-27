From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 1/3] qlge: Restoring the vlan setting.
Date: Tue, 26 Oct 2010 18:13:12 -0700
Message-ID: <20101027011311.GA32239@linux-ox1b.qlogic.org>
References: <20101025194632.GA3545@linux-ox1b.qlogic.org> <AANLkTinr5fHjgPNieYjJuegU2EKWiQG00rAeatZV_=3w@mail.gmail.com> <20101026205422.GC30008@linux-ox1b.qlogic.org> <20101026.142152.71128173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jesse@nicira.com" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ying Ping Lok <ying.lok@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:61430 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760645Ab0J0BZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 21:25:15 -0400
Content-Disposition: inline
In-Reply-To: <20101026.142152.71128173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 02:21:52PM -0700, David Miller wrote:
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Tue, 26 Oct 2010 13:54:22 -0700
> 
> > On Mon, Oct 25, 2010 at 05:56:57PM -0700, Jesse Gross wrote:
> >> 
> >> Using vlan groups within a driver is now deprecated.  I realize that
> >> this is just a bug fix but it would nice if we can avoid introducing
> >> more code around vlan groups.  Of course, fully switching the driver
> >> over to use the new vlan model would be even nicer.
> > 
> > I would like this bug fix to be applied though we will schedule switching
> > to the new vlan model ASAP.
> 
> Then why did you put "net-next-2.6" in the subject lines?

It should have been by itself against net-2.6.  I will re-spin these
patches.

