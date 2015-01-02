From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fddi: skfp: smt.c: Remove unused function
Date: Fri, 02 Jan 2015 16:40:00 -0500 (EST)
Message-ID: <20150102.164000.1127873983127267720.davem@davemloft.net>
References: <1420131686-30895-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420131686-30895-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Thu,  1 Jan 2015 18:01:26 +0100

> Remove the function smt_ifconfig() that is not used anywhere.
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
