From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10 net-next 0/6] net: low latency Ethernet device
 polling
Date: Mon, 10 Jun 2013 13:41:16 -0700 (PDT)
Message-ID: <20130610.134116.1913599114372510768.davem@davemloft.net>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Mon, 10 Jun 2013 11:39:30 +0300

> I removed the select/poll patch (was 5/7 in v9) from the set.
> The rest are the same patches that were in v9.
> 
> Please consider applying.
> 
> Thanks to everyone for their input.

There used to be a really nice, detailed and verbose, description of
the goals and general idea of these changes, along with a lot of
benchmark data.

Now I don't see it, either here in this posting, or in any of the
patch commit messages.

Don't get rid of stuff like that, for a set of changes of this
magnitude you can basically consider such details descriptions
and information mandatory.

Reply to this email with some text to put in the merge commit,
including basic benchmark results, so that I can apply this series.

Thanks.
