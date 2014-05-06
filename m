From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 13:16:43 -0400 (EDT)
Message-ID: <20140506.131643.994244006906866938.davem@davemloft.net>
References: <20140506155703.GA20391@cloud>
	<20140506.115941.428706504757835279.davem@davemloft.net>
	<20140506164108.GA20536@cloud>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506164108.GA20536@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: josh@joshtriplett.org
Date: Tue, 6 May 2014 09:41:08 -0700

> Every KB of RAM costs real money and SoC die area (for eDRAM/eSRAM).

Another poster commented that 16MB of DRAM would be cheaper than
the 2MB of ram you have on these boards, probably one that fits
your size profile is available as well.

2MB is just a rediculous restriction.

And last time I checked Linux wasn't a special purpose operating
system, but lucky for you I hear there are lots of those around.
