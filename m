From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/15] module_param: make bool parameters really bool
 (net & drivers/net)
Date: Thu, 15 Dec 2011 23:15:17 -0500 (EST)
Message-ID: <20111215.231517.185391590658983405.davem@davemloft.net>
References: <877h1ysenl.fsf@rustcorp.com.au>
	<1323920752.29500.11.camel@joe2Laptop>
	<87k45xqvfs.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linux-kernel@vger.kernel.org, pawel.moll@arm.com,
	netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k45xqvfs.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 16 Dec 2011 09:44:31 +1030

> Dave, did you want a true/false cleanup too?

Please, this kind of stuff rots forever and not using bool properly
drives me crazy.
