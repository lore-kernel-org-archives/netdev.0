From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-01-27
Date: Fri, 27 Jan 2012 20:42:10 -0500 (EST)
Message-ID: <20120127.204210.1693783796267469687.davem@davemloft.net>
References: <20120127201023.GC2510@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120127201023.GC2510@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 27 Jan 2012 15:10:23 -0500

> Here are a couple of "one-liner" fixes intended for 3.3.
> 
> A mac80211 fix from Eliad Peller fixes a regression from an earlier
> patche that accidentally removed a necessary line of code.  The other
> one from Eliad adds an overlooked assignment necessary for proper
> management of some state information.  Finally, the fix from Johannes
> moves an unlock to include an additional operation within the critical
> section.
> 
> Pleae let me know if there are problems!

Pulled, thanks John.
