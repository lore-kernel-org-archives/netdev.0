From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-10-27
Date: Tue, 28 Oct 2008 11:00:24 -0700 (PDT)
Message-ID: <20081028.110024.197492570.davem@davemloft.net>
References: <20081027220049.GI20389@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754571AbYJ1SBF@vger.kernel.org>
In-Reply-To: <20081027220049.GI20389@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 27 Oct 2008 18:00:49 -0400

> Another round of fixes intended for 2.6.28 (got it right this time!)...
> 
> "p54: fix misbehavings when firmware can't be found" is a little big,
> but it fixes a double free of an IRQ (bug 11782). "ath5k: Reset key
> cache on interface up, thus fixing resume" is a little sizable too, but
> it moves some code intelligently to fix a regression we introduce on
> resume.  The other stuff is cleanups and a kernel-doc fix, as well as an
> initialization fix for rfkill.
> 
> Please let me know if there are problems!

Looks good, pulled, thanks a lot John.
