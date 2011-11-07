From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: build failure after merge of the origin tree
Date: Sun, 6 Nov 2011 21:29:36 -0800
Message-ID: <EAE7BD3E-8965-47A4-B3CA-01686E2602C2@intel.com>
References: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
 <20111106.205259.1237400984015921904.davem@davemloft.net>
 <20111107134706.3e7fc633f913b5e155153127@canb.auug.org.au>
 <20111106.223619.1348742215191441592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111106.223619.1348742215191441592.davem@davemloft.net>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Cheers,
Jeff

On Nov 6, 2011, at 19:38, "David Miller" <davem@davemloft.net> wrote:

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 7 Nov 2011 13:47:06 +1100
> 
>>> If you just revert the commit in origin from -next, then you will get
>>> conflicts with you pull the net.git tree in.
>> 
>> I got no conflicts when I merged in the net tree and can see no fix for
>> this problem in the net tree.  My current head of the net tree is 1a6422f
>> "etherh: Add MAINTAINERS entry for etherh".
> 
> Ok, Jeff please take a look at this and send me a fix soon.
> 
> Thanks.

Ok Dave, at this point, I am puttying together a patch to revert this fix since it appears that more trouble comes with this fix.  I will take a look at it quickly before sending out a patch to fix the issue.