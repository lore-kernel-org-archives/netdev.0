From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: horizon: Remove some unused functions
Date: Tue, 13 Jan 2015 17:28:29 -0500 (EST)
Message-ID: <20150113.172829.1548714500294830320.davem@davemloft.net>
References: <1421175021-6022-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421175021-6022-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Tue, 13 Jan 2015 19:50:21 +0100

> Removes some functions that are not used anywhere:
> channel_to_vpivci() query_tx_channel_config() rx_disabled_handler()
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
