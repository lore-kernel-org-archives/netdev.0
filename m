From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/5] stmmac code tidy-up (v2)
Date: Mon, 08 Apr 2013 16:57:31 -0400 (EDT)
Message-ID: <20130408.165731.1552732592229203051.davem@davemloft.net>
References: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shiraz.hashim@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964971Ab3DHU5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:57:32 -0400
In-Reply-To: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  8 Apr 2013 14:09:58 +0200

> These patches review and tidy-up the driver to respect the codying-style rules
> where there were some problems.
> Also now kernel-doc passes w/o any warnings.
> These review the stmmac.txt where some new fields have not been
> updated after adding new supports.
> There is a patch to review the private structure trying to reorganize all the fields
> in order to keep adjacent fields for cache effect (this patch is the V2 because
> already discussed in the mailing list). I have seen that there are not
> regressions when test on UP and SMP systems indeed.
> In these patches I have removed two old patches for memory barrier and GRO.
> We discussed about these in the mainling list and these had to be discarded.

Series applied, thanks.
