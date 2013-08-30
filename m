From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5][net-next.git] driver:net:stmmac: Disable DMA store
 and forward mode if platform data force_thresh_dma_mode is set.
Date: Fri, 30 Aug 2013 17:26:50 -0400 (EDT)
Message-ID: <20130830.172650.366477630437476013.davem@davemloft.net>
References: <1377687339-18019-1-git-send-email-sonic.adi@gmail.com>
	<521DE637.6030801@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sonic.adi@GMAIL.COM, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278Ab3H3V0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:26:52 -0400
In-Reply-To: <521DE637.6030801@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 28 Aug 2013 13:59:51 +0200

> On 8/28/2013 12:55 PM, Sonic Zhang wrote:
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Some synopsys ip implementation doesn't support DMA store and forward
>> mode,
>> such as BF60x. So, set force_thresh_dma_mode to use DMA thresholds
>> only.
>> Update document and devicetree as well.
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> 
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
