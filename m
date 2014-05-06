From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 13:25:01 -0400 (EDT)
Message-ID: <20140506.132501.331724703594119414.davem@davemloft.net>
References: <20140506164546.GB20536@cloud>
	<20140506.131752.740569380523989782.davem@davemloft.net>
	<20140506172106.GB20776@cloud>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506172106.GB20776@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: josh@joshtriplett.org
Date: Tue, 6 May 2014 10:21:06 -0700

> On Tue, May 06, 2014 at 01:17:52PM -0400, David Miller wrote:
>> From: josh@joshtriplett.org
>> Date: Tue, 6 May 2014 09:45:46 -0700
>> 
>> > The kernel can do the same.  Consider the idea of analyzing a set of
>> > userspace programs, determining what kernel functionality they do and
>> > don't need, feeding that information into the kernel build process, and
>> > automatically dropping unused bits of the kernel.
>> 
>> Please make sure I'm not on the list of people who see reports for
>> bugs reported in that setup.
>> 
>> Thanks :-)
> 
> Fine by me.  Just please allow such a setup to exist. :)

You see, that's the point I'm trying to make, once it's upstream
then it's my problem.

You absolutely must consider the burdon you put upon upstream
maintainers when you ask for things to be included.
