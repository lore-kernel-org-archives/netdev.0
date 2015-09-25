From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH] net/ibm/emac: bump version numbers for correct work
 with ethtool
Date: Fri, 25 Sep 2015 08:07:52 +0400
Message-ID: <20150925080752.14a2fee6@fr-ThinkPad-W520>
References: <20150923144222.66de305c@fr-ThinkPad-W520>
	<20150923.110549.113067983983388057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<benh@kernel.crashing.org>, "Ben Hutchings" <ben@decadent.org.uk>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923.110549.113067983983388057.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Sep 2015 11:05:49 -0700 (PDT)
"David Miller" <davem@davemloft.net> wrote:

> From: Ivan Mikhaylov <ivan@ru.ibm.com>
> Date: Wed, 23 Sep 2015 14:42:22 +0400
> 
> > Register dump out work preventing with 
> > old ethtool + new driver and new ethtool + old driver.
> 
> First of all you didn't provide a proper Signoff.
> 
> Second of all, there was so much discussion about whether this does
> or does not break things for various combinations of old/new ethtool
> and kernel.
> 
> Therefore I want a real detailed commit message that explains why this
> is all OK.  After so much confusion and discussion, providing a patch
> with absolutely no commit message is completely inappropriate.

David, my apologies for signoff and description, I admit that is inappropriate.
Ben proposed one, is it eligible?
Need I resubmit patch with sign and detailed description?
