From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] drivers/isdn/gigaset/common.c: Remove useless kfree
Date: Thu, 13 Sep 2012 17:05:44 -0400 (EDT)
Message-ID: <20120913.170544.700934810225924264.davem@davemloft.net>
References: <1347462407-13499-9-git-send-email-peter.senna@gmail.com>
	<5051ACDB.5030407@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.senna@gmail.com, hjlipp@web.de,
	kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5051ACDB.5030407@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Thu, 13 Sep 2012 11:52:27 +0200

> Am 12.09.2012 17:06, schrieb Peter Senna Tschudin:
>> From: Peter Senna Tschudin <peter.senna@gmail.com>
>> 
>> Remove useless kfree() and clean up code related to the removal.
>> 
>> The semantic patch that finds this problem is as follows:
> [...]
>> 
>> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
> 
> Acked-by: Tilman Schmidt <tilman@imap.cc>

Applied to net-next, thanks.
