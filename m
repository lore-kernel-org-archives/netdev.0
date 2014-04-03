From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdnloop: Validate NUL-terminated strings from user.
Date: Thu, 03 Apr 2014 11:27:00 -0400 (EDT)
Message-ID: <20140403.112700.1784911571711405881.davem@davemloft.net>
References: <20140401.161838.1562296825577866979.davem@davemloft.net>
	<533B889A.2060105@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vegard.nossum@oracle.com, dan.carpenter@oracle.com
To: yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533B889A.2060105@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 02 Apr 2014 12:48:42 +0900

> Return -EINVAL unless all of user-given strings are correctly
> NUL-terminated.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied and queud up for -stable, thanks!
