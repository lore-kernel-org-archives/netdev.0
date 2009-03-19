From: David Miller <davem@davemloft.net>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 22:38:06 -0700 (PDT)
Message-ID: <20090318.223806.123468340.davem@davemloft.net>
References: <49C16D7C.3080003@novell.com>
	<20090318.180355.228447835.davem@davemloft.net>
	<49C1C09E.8050405@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: ghaskins@novell.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <49C1C09E.8050405@novell.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory Haskins <ghaskins@novell.com>
Date: Wed, 18 Mar 2009 23:48:46 -0400

> To see this in action, try taking a moderately large smp system
> (8-way+) and scaling the number of flows.

I can maintain line-rate over 10GB with a 64-cpu box.  It's not
a problem.
