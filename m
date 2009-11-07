From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-11-06
Date: Fri, 06 Nov 2009 18:22:15 -0800 (PST)
Message-ID: <20091106.182215.230775367.davem@davemloft.net>
References: <20091106204034.GI2782@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758434AbZKGCVv@vger.kernel.org>
In-Reply-To: <20091106204034.GI2782@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 6 Nov 2009 15:40:34 -0500

> Three more intended for 2.6.32, two oops fixes and a revert of a patch
> that traded one bug for another.  One of the oops fixes reorders some
> cancel_delayed_work_sync calls and the other does some bit testing to
> avoid scheduling work after a device has been removed.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
