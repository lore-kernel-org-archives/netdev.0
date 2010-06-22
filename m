From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-06-22
Date: Tue, 22 Jun 2010 10:54:53 -0700 (PDT)
Message-ID: <20100622.105453.35051747.davem@davemloft.net>
References: <20100622174136.GC2583@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100622174136.GC2583@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 22 Jun 2010 13:41:37 -0400

> Just a single fix this time, a patch for ath5k to avoid a null pointer
> dereference that can happen when executing certain operations against a
> newly created interface.  This is, of course, intended for 2.6.35.
> 
> Please let me know if there are problems!

Pulled, thanks John.
