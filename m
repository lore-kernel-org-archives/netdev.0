From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH - diffstat only] include/net: Remove extern from
 function prototypes
Date: Tue, 30 Jul 2013 00:10:01 -0700 (PDT)
Message-ID: <20130730.001001.618776305200728182.davem@davemloft.net>
References: <1374602291.3387.17.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374602291.3387.17.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 23 Jul 2013 10:58:11 -0700

> Function prototypes don't need to be declared
> extern in .h files.  It's assumed by the compiler
> and is as unnecessary as using auto is when
> declaring automatic/local variables in a block.
> 
> I ran a script to remove these unnecessary extern
> uses from function prototypes in include/net/ as
> well as reflow the function arguments to 80 cols.
> 
> It's 370KB, far too large to submit at once.
> 
> Of course it could be broken into multiple patches
> for the various directories/subsystems.

No objections from me.

Please submit a small number at a time so that my already overflowing
backlog isn't overwhelmed even more.

Thanks.
