From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpmac.c: Cleaning up missing
 null-terminate after strncpy call
Date: Mon, 11 Aug 2014 12:28:18 -0700 (PDT)
Message-ID: <20140811.122818.193540699184570884.davem@davemloft.net>
References: <1407627707-24303-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407627707-24303-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun, 10 Aug 2014 01:41:47 +0200

> Added a guaranteed null-terminate after call to strncpy.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
