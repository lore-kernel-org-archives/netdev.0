From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Add ethtool get_ringparam and set_ringparam to
 cadence
Date: Wed, 19 Oct 2016 15:18:36 -0400 (EDT)
Message-ID: <20161019.151836.1970381994363651324.davem@davemloft.net>
References: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: zach.brown@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@ni.com>
Date: Wed, 19 Oct 2016 09:56:56 -0500

> There are use cases like RT that would benefit from being able to tune the
> macb rx/tx ring sizes. The ethtool set_ringparam function is the standard way
> of doing so.
> 
> The first patch changes the hardcoded tx/rx ring sizes to variables that are
> set to a hardcoded default.
> 
> The second patch implements the get_ringparam and set_ringparam fucntions.

Series applied, thanks.
