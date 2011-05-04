From: David Miller <davem@davemloft.net>
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 04 May 2011 11:56:49 -0700 (PDT)
Message-ID: <20110504.115649.48491788.davem@davemloft.net>
References: <4DC178D3.6030308@techboom.com>
	<20110504104940.cd0d9e9a.rdunlap@xenotime.net>
	<20110504113351.4643a0c9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, lkml@techboom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110504113351.4643a0c9@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 May 2011 11:33:51 -0700

> On Wed, 4 May 2011 10:49:40 -0700
> Randy Dunlap <rdunlap@xenotime.net> wrote:
> 
>> > [28522.642590] Pid: 0, comm: swapper Not tainted 2.6.38.5 #6
                                                      ^^^^^^^^

>> > 
>> >   Supermicro X8DTH-i/6/iF/6F
>> > /
>> >   X8DTH
>> > 
> 
> What kernel version?

It's right there in the dump Stephen, see above.
