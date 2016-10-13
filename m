From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 2/2] stmmac: fix error check when init ptp
Date: Thu, 13 Oct 2016 11:01:20 -0400 (EDT)
Message-ID: <20161013.110120.568098679338919139.davem@davemloft.net>
References: <1476279724-11817-1-git-send-email-peppe.cavallaro@st.com>
        <1476279724-11817-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexandre.torgue@st.com, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476279724-11817-2-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 12 Oct 2016 15:42:04 +0200

> This patch fixes a problem when propagated the
> failure of ptp_clock_register to open function.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
