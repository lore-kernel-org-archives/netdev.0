From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: stmmac: Fix altr_tse_pcs SGMII
 Initialization
Date: Fri, 02 Jun 2017 14:20:34 -0400 (EDT)
Message-ID: <20170602.142034.253393114837715246.davem@davemloft.net>
References: <1496258927-5493-1-git-send-email-thor.thayer@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thor.thayer@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496258927-5493-1-git-send-email-thor.thayer@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: thor.thayer@linux.intel.com
Date: Wed, 31 May 2017 14:28:47 -0500

> From: Thor Thayer <thor.thayer@linux.intel.com>
> 
> Fix NETDEV WATCHDOG timeout on startup by adding missing register
> writes that properly setup SGMII.
> 
> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>

Applied, thank you.
