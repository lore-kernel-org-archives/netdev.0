From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 21:19:11 +0200
Message-ID: <20140506191911.GC4137@netboy>
References: <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
 <20140506.131643.994244006906866938.davem@davemloft.net>
 <20140506175547.GE20776@cloud>
 <CAM_iQpUgj7BqpzRL070DEGQ32SWwN68BRgM5DtFqvBLjGGOLQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Triplett <josh@joshtriplett.org>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49407 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbaEFTTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 15:19:23 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpUgj7BqpzRL070DEGQ32SWwN68BRgM5DtFqvBLjGGOLQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 11:33:11AM -0700, Cong Wang wrote:
> 
> So why bothers 3.15+ Linux kernel? Why not use an old kernel e.g. 2.4.x?
> 2.4.x kernel doesn't have so many new features you want to get rid of here.

If you compare a 3.x and a 2.4.x kernel with the same minimal feature
set, you might see that the 3.x is bigger.

Thanks,
Richard
