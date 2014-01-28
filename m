From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the bluetooth tree with the
 net/net-next trees
Date: Mon, 27 Jan 2014 16:43:42 -0800 (PST)
Message-ID: <20140127.164342.1026192370176923084.davem@davemloft.net>
References: <20140107125418.986ae20298ddc55e5e657447@canb.auug.org.au>
	<20140128095415.8382335c33545ad14d4be067@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gustavo@padovan.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	dborkman@redhat.com, jukka.rissanen@linux.intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140128095415.8382335c33545ad14d4be067@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 28 Jan 2014 09:54:15 +1100

> On Tue, 7 Jan 2014 12:54:18 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
 ...
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Tue, 7 Jan 2014 12:52:43 +1100
>> Subject: [PATCH] net: 6lowpan: fixup for code movement
>> 
>> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
 ...
> I think this fix patch got missed when bluetooth was merged ... so it
> should probably go into the net tree.

Good catch, applied, thanks Stephen!
