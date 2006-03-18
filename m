From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [2.6 patch] ieee80211_wx.c: remove dead code
Date: Fri, 17 Mar 2006 20:14:14 -0500
Message-ID: <20060318011409.GH25249@tuxdriver.com>
References: <20060315164015.GZ13973@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932830AbWCRBRa@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060315164015.GZ13973@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2006 at 05:40:15PM +0100, Adrian Bunk wrote:
> Since sec->key_sizes[] is an u8, len can't be < 0.
> 
> Spotted by the Coverity checker.

Merged to upstream branch of wireless-2.6...thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
