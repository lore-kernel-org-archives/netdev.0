From: David Miller <davem@davemloft.net>
Subject: Re: net/mac80211/rx.c: fix build error
Date: Sun, 12 Oct 2008 23:52:04 -0700 (PDT)
Message-ID: <20081012.235204.37529445.davem@davemloft.net>
References: <20081013064135.GA19719@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com,
	davidepesa@gmail.com, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756137AbYJMGwm@vger.kernel.org>
In-Reply-To: <20081013064135.GA19719@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 13 Oct 2008 08:41:35 +0200

> 
> FYI, the fixlet below is still needed, even after b0dee578 ("Fix modpost 
> failure when rx handlers are not inlined."). The build error triggered 
> on a -tip testbox.

Fair enough, applied, thanks.
