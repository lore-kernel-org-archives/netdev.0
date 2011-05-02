From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-05-02
Date: Mon, 02 May 2011 12:24:19 -0700 (PDT)
Message-ID: <20110502.122419.193698649.davem@davemloft.net>
References: <20110502182013.GA6768@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110502182013.GA6768@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 2 May 2011 14:20:13 -0400

> Dave,
> 
> Here are a few more intended for 2.6.39.  There is a one-liner for b43
> which adds a missing MODULE_FIRMWARE declaration (so maybe someone's
> initrd will get generated correctly), an iwlegacy fix from Wey-Yi that
> corrects an LED flashing change that people are complaining about,
> an iwl4965 WARNING fix from Stanislaw, and a matching pair of iwlagn
> and iwl4965 regression fixes also from Stanislaw that correct problems
> with using the wrong station ID for block ACK sessions.
> 
> Please let me know if there are problems!
> 
> John
> 
> P.S.  I know the LED flashing fix is questionable, but it is an
> annoyance and it should not effect any other hardware.

Looks fine, pulled, thanks John.
