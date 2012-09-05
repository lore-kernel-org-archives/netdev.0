From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: fix shutdown parameter checking
Date: Wed, 05 Sep 2012 13:00:20 -0400 (EDT)
Message-ID: <20120905.130020.768517336834373231.davem@davemloft.net>
References: <1346059001.2703.7.camel@menhir>
	<20120831.155719.2228399422573401952.davem@davemloft.net>
	<1346834276.2799.4.camel@menhir>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xi.wang@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: swhiteho@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346834276.2799.4.camel@menhir>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Wed, 05 Sep 2012 09:37:56 +0100

> However, I'm not overly worried and we'll soon know if it will cause any
> problems or not,

You can be sure that if we get real bug reports due to this change, I will
revert it back to how it was before.
