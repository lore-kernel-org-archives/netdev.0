From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cisco: enic: enic_dev: Remove some
 unused functions
Date: Fri, 02 Jan 2015 16:40:19 -0500 (EST)
Message-ID: <20150102.164019.754021420669768265.davem@davemloft.net>
References: <1420230564-2060-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, ssujith@cisco.com, _govind@gmx.com,
	neepatel@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420230564-2060-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Fri,  2 Jan 2015 21:29:24 +0100

> Removes some functions that are not used anywhere:
> enic_dev_enable2_done() enic_dev_enable2() enic_dev_deinit_done()
> enic_dev_init_prov2() enic_vnic_dev_deinit()
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
