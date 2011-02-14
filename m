From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: enable wol via magic frame by default.
Date: Sun, 13 Feb 2011 17:00:14 -0800 (PST)
Message-ID: <20110213.170014.124073570.davem@davemloft.net>
References: <1297414306-11271-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755316Ab1BNA7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 19:59:38 -0500
In-Reply-To: <1297414306-11271-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 11 Feb 2011 09:51:46 +0100

> This patch enables it by default when the driver starts.
> This has been required by many people and seems to actually be
> useful on STB.
> At any rate, the WoL modes can be selected and turned-on/off
> by using the ethtool at run-time by users.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
