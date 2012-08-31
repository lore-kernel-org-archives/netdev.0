From: David Miller <davem@davemloft.net>
Subject: Re: [Stlinux-devel] [PATCH linux-stm 4/4] net:stmmac: convert
 driver to use devm_request_and_ioremap.
Date: Fri, 31 Aug 2012 16:13:06 -0400 (EDT)
Message-ID: <20120831.161306.532589808957225845.davem@davemloft.net>
References: <1346341869-20211-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037Ab2HaUNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:13:08 -0400
In-Reply-To: <1346341869-20211-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Thu, 30 Aug 2012 16:51:09 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch moves calls to ioremap and request_mem_region to
> devm_request_and_ioremap call.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied.
