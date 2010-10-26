From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 1/3] qlge: Restoring the vlan setting.
Date: Tue, 26 Oct 2010 13:54:22 -0700
Message-ID: <20101026205422.GC30008@linux-ox1b.qlogic.org>
References: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com> <1288023473-31490-2-git-send-email-ron.mercer@qlogic.com> <20101025.120739.104054830.davem@davemloft.net> <20101025194632.GA3545@linux-ox1b.qlogic.org> <AANLkTinr5fHjgPNieYjJuegU2EKWiQG00rAeatZV_=3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ying Ping Lok <ying.lok@qlogic.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:57967 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756909Ab0JZVGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 17:06:25 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinr5fHjgPNieYjJuegU2EKWiQG00rAeatZV_=3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 05:56:57PM -0700, Jesse Gross wrote:
> 
> Using vlan groups within a driver is now deprecated.  I realize that
> this is just a bug fix but it would nice if we can avoid introducing
> more code around vlan groups.  Of course, fully switching the driver
> over to use the new vlan model would be even nicer.

I would like this bug fix to be applied though we will schedule switching
to the new vlan model ASAP.

