From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: ipq806x: Return error values instead of
 pointers
Date: Thu, 03 Dec 2015 15:27:17 -0500 (EST)
Message-ID: <20151203.152717.1108068845756443724.davem@davemloft.net>
References: <1449129315-1427-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	peppe.cavallaro@st.com, netdev@vger.kernel.org, manabian@gmail.com
To: sboyd@codeaurora.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1449129315-1427-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Wed,  2 Dec 2015 23:55:15 -0800

> Typically we return error pointers when we want to use those
> pointers in the non-error case, but this function is just
> returning error pointers or NULL for success. Change the style to
> plain int to follow normal kernel coding styles.
> 
> Cc: Joachim Eastwood <manabian@gmail.com>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Applied.
