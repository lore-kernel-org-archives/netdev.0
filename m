From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: toshiba: ps3_gelic_net.c: Cleaning up a
 check on a memory allocation
Date: Wed, 11 Jun 2014 00:15:31 -0700 (PDT)
Message-ID: <20140611.001531.1896504886716747190.davem@davemloft.net>
References: <1402136528-16857-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geoff@infradead.org, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402136528-16857-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sat,  7 Jun 2014 12:22:08 +0200

> A check on a memory allocation is checked incorrectly.
> 
> This was partly found using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
