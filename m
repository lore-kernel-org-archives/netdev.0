From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] stmmac: add the experimental PCI support
Date: Wed, 21 Dec 2011 15:45:14 -0500 (EST)
Message-ID: <20111221.154514.687926099723159992.davem@davemloft.net>
References: <4EF1E582.5050300@st.com>
	<1324475900-1470-1-git-send-email-peppe.cavallaro@st.com>
	<1324475900-1470-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab1LUUpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:45:21 -0500
In-Reply-To: <1324475900-1470-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 21 Dec 2011 14:58:19 +0100

> This patch adds the PCI support (as EXPERIMENTAL)
> this has been also tested on XLINX XC2V3000 FF1152AMT0221
> D1215994A VIRTEX FPGA board.
> To support the PCI bus the main part has been reworked
> and both the platform and the PCI specific parts have
> been moved into different files.
> 
> Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
