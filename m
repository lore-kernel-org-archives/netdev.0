From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: treewide: Fix typo found in DocBook/networking.xml
Date: Wed, 03 Sep 2014 20:38:14 -0700 (PDT)
Message-ID: <20140903.203814.642492840095995090.davem@davemloft.net>
References: <1409716755-1994-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, rdunlap@infradead.org,
	linux-doc@vger.kernel.org, trivial@kernel.org
To: standby24x7@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1409716755-1994-1-git-send-email-standby24x7@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masanari Iida <standby24x7@gmail.com>
Date: Wed,  3 Sep 2014 12:59:15 +0900

>   * When used in combination with the softirq_exit tracepoint
> - * we can determine the softirq handler runtine.
> + * we can determine the softirq handler runtime.
>   */

The author of this comment meant to say "routine" not "runtime"
