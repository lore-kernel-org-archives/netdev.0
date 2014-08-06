From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: Change disable flag from bool to a bit
Date: Wed, 06 Aug 2014 14:07:22 -0700 (PDT)
Message-ID: <20140806.140722.489043833669403528.davem@davemloft.net>
References: <1407348973-2433-1-git-send-email-zoltan.kiss@citrix.com>
	<1407348973-2433-5-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407348973-2433-5-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 6 Aug 2014 19:16:13 +0100

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Neither this nor your "Small fixes around internal queue purging"
patch apply cleanly to my current tree.  I have no idea what tree you
are sending these patches against.
