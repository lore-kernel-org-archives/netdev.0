From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 11:48:40 -0700
Message-ID: <20140506184840.GN19657@tassilo.jf.intel.com>
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
	LKML <linux-kernel@vger.kernel.org>, tom.zanussi@linux.intel.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpUgj7BqpzRL070DEGQ32SWwN68BRgM5DtFqvBLjGGOLQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So why bothers 3.15+ Linux kernel? Why not use an old kernel e.g. 2.4.x?
> 2.4.x kernel doesn't have so many new features you want to get rid of here.

Nobody wants to be stuck on an ancient kernel forever.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
