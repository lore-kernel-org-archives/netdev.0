From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qlge: Restoring the vlan setting.
Date: Tue, 26 Oct 2010 14:21:52 -0700 (PDT)
Message-ID: <20101026.142152.71128173.davem@davemloft.net>
References: <20101025194632.GA3545@linux-ox1b.qlogic.org>
	<AANLkTinr5fHjgPNieYjJuegU2EKWiQG00rAeatZV_=3w@mail.gmail.com>
	<20101026205422.GC30008@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753080Ab0JZVV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 17:21:29 -0400
In-Reply-To: <20101026205422.GC30008@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue, 26 Oct 2010 13:54:22 -0700

> On Mon, Oct 25, 2010 at 05:56:57PM -0700, Jesse Gross wrote:
>> 
>> Using vlan groups within a driver is now deprecated.  I realize that
>> this is just a bug fix but it would nice if we can avoid introducing
>> more code around vlan groups.  Of course, fully switching the driver
>> over to use the new vlan model would be even nicer.
> 
> I would like this bug fix to be applied though we will schedule switching
> to the new vlan model ASAP.

Then why did you put "net-next-2.6" in the subject lines?
