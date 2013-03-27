From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Wed, 27 Mar 2013 13:11:02 -0400 (EDT)
Message-ID: <20130327.131102.1330147430632825736.davem@davemloft.net>
References: <1364382973-5047-1-git-send-email-kapranoff@inbox.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, joe@perches.com, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org
To: kapranoff@inbox.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364382973-5047-1-git-send-email-kapranoff@inbox.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Kapranov <kapranoff@inbox.ru>
Date: Wed, 27 Mar 2013 15:16:13 +0400

> In case of fixed speed set up for a NIC (e.g. ethtool -s eth0 autoneg off speed
> 100 duplex full) with an ethernet cable plugged off, the mentioned algorithm
> slows down a NIC speed, so further cable hook-up leads to nonoperable link state.
> 
> Signed-off-by: Kirill Kapranov <kapranoff@inbox.ru>

Applied.
