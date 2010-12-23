From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-12-22
Date: Wed, 22 Dec 2010 17:35:13 -0800 (PST)
Message-ID: <20101222.173513.102576612.davem@davemloft.net>
References: <20101222195209.GD10046@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101222195209.GD10046@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 22 Dec 2010 14:52:09 -0500

> Dave,
> 
> Three more fixes intended for 2.6.37...
> 
> The one from Johannes Berg avoids a NULL pointer dereference in the mesh
> code.  The one from Johannes Stezenbach fixes bug 24892, which is a
> lock-up caused by rt2x00.  Finally, you probably recognize the one from
> Meelis Roos which removes some log spam coming from hostap.  These have
> all spent several days in linux-next without any adverse effects.
> 
> Please let me know if there are problems!

Pulled, thanks John.
