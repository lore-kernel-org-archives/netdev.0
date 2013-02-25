From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/pasemi: Fix missing coding style
Date: Sun, 24 Feb 2013 20:13:01 -0500 (EST)
Message-ID: <20130224.201301.457851300548359313.davem@davemloft.net>
References: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olof@lixom.net
To: syamsidhardh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759537Ab3BYBNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 20:13:05 -0500
In-Reply-To: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Syam Sidhardhan <syamsidhardh@gmail.com>
Date: Mon, 25 Feb 2013 04:31:19 +0530

> -		} else
> +		} else {
>  			freed = 2;
> +		}

Single line statements do not need braces.
