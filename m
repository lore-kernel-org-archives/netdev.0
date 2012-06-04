From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 0/3 (v2)] stmmac fixes for net.git
Date: Mon, 04 Jun 2012 14:11:38 -0400 (EDT)
Message-ID: <20120604.141138.1776852288038469567.davem@davemloft.net>
References: <1338827531-10376-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248Ab2FDSLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 14:11:43 -0400
In-Reply-To: <1338827531-10376-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  4 Jun 2012 18:32:08 +0200

> These patches fix a problem in the driver when built as dynamic
> module and fix the driver's documentation.
> 
> v2: this patchset has the same patches I had sent before but
>     I removed a patch that did a cleanup (now moved for net-next).
> 
> Giuseppe Cavallaro (3):
>   stmmac: fix driver's doc when run kernel-doc script
>   stmmac: update driver's doc
>   stmmac: fix driver Kconfig when built as module

Still not right, see Ben's feedback.
