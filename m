From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 16:47:42 -0400 (EDT)
Message-ID: <20140506.164742.951623564368259138.davem@davemloft.net>
References: <20140506172106.GB20776@cloud>
	<20140506.132501.331724703594119414.davem@davemloft.net>
	<20140506200644.GC5619@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: josh@joshtriplett.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506200644.GC5619@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 6 May 2014 22:06:44 +0200

>> You see, that's the point I'm trying to make, once it's upstream
>> then it's my problem.
> 
> FWIW I don't think any of the changes I proposed would be likely
> to add lots of new bugs.

Then you're living in a dream world, one in which the rest of us do
not live in.

Every new configuration combination is a new situation that competes
testing wise with the others.
