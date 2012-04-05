From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxge: Convert macro to inline function
Date: Wed, 04 Apr 2012 20:33:13 -0400 (EDT)
Message-ID: <20120404.203313.756996430678321892.davem@davemloft.net>
References: <1333491271.2695.20.camel@joe2Laptop>
	<20120403.181830.799733266830291210.davem@davemloft.net>
	<1333579075.23520.19.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333579075.23520.19.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 04 Apr 2012 15:37:55 -0700

> On Tue, 2012-04-03 at 18:18 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Tue, 03 Apr 2012 15:14:31 -0700
>> > Convert the macro to inline function to check the arguments.
>> > Signed-off-by: Joe Perches <joe@perches.com>
>> > ---
>> >> Longer term I'd much rather see this turned into an inline
>> >> function with proper type checking etc.
>> > Something like this?
>> Yep.
> 
> I did sign the patch.
> I was intending that you could apply it.

Ok, I see now, applied.  Thanks Joe.
