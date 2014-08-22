From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: simple cleanups
Date: Fri, 22 Aug 2014 12:34:08 -0700 (PDT)
Message-ID: <20140822.123408.2064974279443073401.davem@davemloft.net>
References: <20140819105646.GA27984@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140819105646.GA27984@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Tue, 19 Aug 2014 12:56:46 +0200

> This adds simple cleanups for stmmac, removing test we know is always
> true, fixing whitespace, and moving code out of if().
> 
> Signed-off-by: Pavel Machek <pavel@denx.de>

This does not apply cleanly to the current net-next tree.
