From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: hfc4s8s_l1: Remove some unused functions
Date: Fri, 02 Jan 2015 16:40:09 -0500 (EST)
Message-ID: <20150102.164009.2208912516300295493.davem@davemloft.net>
References: <1420139842-3573-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, dan.carpenter@oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420139842-3573-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Thu,  1 Jan 2015 20:17:22 +0100

> Removes some functions that are not used anywhere:
> Read_hfc32() Write_hfc32() Write_hfc16()
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
