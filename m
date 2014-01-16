From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/9] net: stmmac PM related fixes.
Date: Thu, 16 Jan 2014 15:24:23 -0800 (PST)
Message-ID: <20140116.152423.417924760541282210.davem@davemloft.net>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
	<1389869321-27411-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	linux-kernel@vger.kernel.org
To: srinivas.kandagatla@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389869321-27411-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <srinivas.kandagatla@st.com>
Date: Thu, 16 Jan 2014 10:48:41 +0000

> During PM_SUSPEND_FREEZE testing, I have noticed that PM support in STMMAC is
> partly broken. I had to re-arrange the code to do PM correctly. There were lot
> of things I did not like personally and some bits did not work in the first
> place. I thought this is the nice opportunity to clean the mess up.

Series applied to net-next, thanks.
