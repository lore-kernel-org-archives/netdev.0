From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-10-26
Date: Fri, 26 Oct 2012 15:09:14 -0400 (EDT)
Message-ID: <20121026.150914.698922406187249983.davem@davemloft.net>
References: <20121026152112.GB16104@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121026152112.GB16104@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 26 Oct 2012 11:21:13 -0400

> This is a batch of fixes intended for the 3.7 stream.
> 
> Bing Zhao brings two mwifiex fixes, both continuing to fix some scanning
> failure cases.
> 
> Christian Lamparter provides an rtlwifi fix to properly propogate an
> error code.
> 
> Felix Fietkau reverts a previous fix that was improperly reducing Tx
> power for some devices.  This one looks big, but it is mostly just
> changes to a table of initialization values.
> 
> Larry Finger provides a b43 version of an earlier b43legacy fix to
> avoid and oops when removing the modules after failing to load firmware.
> 
> Mohammed Shafi Shajakhan provides a new device ID for ath9k_htc.
> 
> Stanislaw Gruszka gives us an rt2x00 fix to avoide a WARNING during
> resume, as described in kernel.org bug 48041.
> 
> Yuanhan Liu fixes a potential NULL dereference in brcmfmac.

Pulled, thanks John.
