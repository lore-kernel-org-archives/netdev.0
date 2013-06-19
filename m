From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers/net: param for lapbether for specific
 ethernet device
Date: Wed, 19 Jun 2013 15:48:53 -0700 (PDT)
Message-ID: <20130619.154853.2105911759808459657.davem@davemloft.net>
References: <1371655613-31969-1-git-send-email-steve.moorby@ntlworld.com>
	<20130619.121802.2112053686285060471.davem@davemloft.net>
	<51C21253.2070308@ntlworld.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steve.moorby@ntlworld.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C21253.2070308@ntlworld.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Moorby <steve.moorby@ntlworld.com>
Date: Wed, 19 Jun 2013 21:19:31 +0100

> I will be using an Ubuntu 10.04 kernel with the 'eth_dev' module
> parameter patch.  I appreciate a better solution needs to be designed
> but it is not one I can contribute to.  I still advocate the patch as
> an improvement on the current non functional situation.

We don't put poorly designed changes into the tree simply because
a properly implemented version doesn't exist yet.
