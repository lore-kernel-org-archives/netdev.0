From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 2/4] net: ethtool: add the EEE support
Date: Tue, 6 Mar 2012 16:56:22 +0000
Message-ID: <1331052982.2333.17.camel@bwh-desktop>
References: <4F4E4D4B.3040909@st.com>
	 <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
	 <1331022494-12891-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22107 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752045Ab2CFQ4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 11:56:25 -0500
In-Reply-To: <1331022494-12891-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-06 at 09:28 +0100, Giuseppe CAVALLARO wrote:
> This patch adds two new functions to detect if Energy-Efficient
> Ethernet (EEE) is supported and the way to enable/disable it.
[...]

You haven't fixed any of the problems in the previous version of this
patch.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
