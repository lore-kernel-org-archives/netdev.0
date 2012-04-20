From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/4] stmmac: use custom init/exit functions in pm ops
Date: Thu, 19 Apr 2012 20:06:42 -0400 (EDT)
Message-ID: <20120419.200642.2124146219634804222.davem@davemloft.net>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab2DTAGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 20:06:47 -0400
In-Reply-To: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 19 Apr 2012 07:48:19 +0200

> From: Francesco Virlinzi <francesco.virlinzi@st.com>
> 
> Freeze and restore can call the custom init/exit functions.
> Also the patch adds a custom data field that can be used
> for storing platform data useful on restore the embedded
> setup (e.g. GPIO, SYSCFG).
> 
> Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
