From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rcu: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Sat, 16 Aug 2014 18:50:02 -0700 (PDT)
Message-ID: <20140816.185002.1499212551659532229.davem@davemloft.net>
References: <20140816193442.GA6471@ada>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: bernat.ada@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140816193442.GA6471@ada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please do not use the same exact Subject line for all of these patches.

Otherwise nobody reading the shortlog can tell what might be different
from one patch to another.

Instead, use a subsystem prefix for the place where you're making
your change.  For example, for the two networking patches you could
replace "rcu: " with "bonding: " and "cnic: ".

Thanks.
