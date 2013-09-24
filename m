From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] can: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 10:02:09 -0400 (EDT)
Message-ID: <20130924.100209.1219862004963547693.davem@davemloft.net>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
	<52414128.8030706@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52414128.8030706@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 24 Sep 2013 09:37:12 +0200

> On 09/24/2013 12:11 AM, Joe Perches wrote:
>> There are a mix of function prototypes with and without extern
>> in the kernel sources.  Standardize on not using extern for
>> function prototypes.
>> 
>> Function prototypes don't need to be written with extern.
>> extern is assumed by the compiler.  Its use is as unnecessary as
>> using auto to declare automatic/local variables in a block.
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Thx, added to linux-can-next. The patch will be included in the next
> pull request to David.

Marc, I'm trying to just quickly apply these all into my tree directly.

Thanks.
