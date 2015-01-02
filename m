From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: chelsio: cxgb3: mc5.c: Remove some
 unused functions
Date: Fri, 02 Jan 2015 16:39:54 -0500 (EST)
Message-ID: <20150102.163954.1550479595529880647.davem@davemloft.net>
References: <1420130996-29910-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420130996-29910-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Thu,  1 Jan 2015 17:49:55 +0100

> Removes some functions that are not used anywhere:
> dbgi_rd_rsp3() dbgi_wr_addr3()
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
