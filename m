From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-06-08
Date: Wed, 09 Jun 2010 11:17:23 -0700 (PDT)
Message-ID: <20100609.111723.183033775.davem@davemloft.net>
References: <20100608190214.GD2422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100608190214.GD2422@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 8 Jun 2010 15:02:14 -0400

> Dave,
> 
> Here is a flurry of fixes intended for 2.6.35.  Most of them are small
> and obvious, but there are a few exceptions...I'll include some text from
> the iwlwifi pull request:
...
> The iwlwifi bits are bigger than I would like to see, but the fixes
> seem worthwhile.  Also included is a revert of a hostap patch that
> introduced failures with some devices, a NULL pointer dereference fix,
> a memory leak fix, a fix for an incorrect check of function pointer,
> a USB ID for p54, and a fix for an association failure 'corner case'
> from Johannes.

Pulled, thanks John.

Please try to keep things a lot smaller from here on out, thank you.
