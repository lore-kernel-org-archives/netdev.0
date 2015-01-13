From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: link: Remove unused function
Date: Tue, 13 Jan 2015 17:27:53 -0500 (EST)
Message-ID: <20150113.172753.83063003776927644.davem@davemloft.net>
References: <1421173498-4012-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421173498-4012-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Tue, 13 Jan 2015 19:24:58 +0100

> Remove the function tipc_link_get_max_pkt() that is not used anywhere.
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

This does not apply to net-next.
