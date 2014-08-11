From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: ethernet: myricom: myri10ge: myri10ge.c:
 Cleaning up missing null-terminate after strncpy call
Date: Mon, 11 Aug 2014 14:57:26 -0700 (PDT)
Message-ID: <20140811.145726.257229777777517083.davem@davemloft.net>
References: <1407784696-31698-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hykim@myri.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407784696-31698-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Mon, 11 Aug 2014 21:18:16 +0200

> Added a guaranteed null-terminate after call to strncpy.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
