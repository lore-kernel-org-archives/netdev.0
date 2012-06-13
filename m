From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1 v3] Ethtool: Add EEE support
Date: Wed, 13 Jun 2012 22:39:29 +0100
Message-ID: <1339623569.2612.58.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339318088-27126-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eilong@broadcom.com>,
	<peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17736 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750770Ab2FMVjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 17:39:35 -0400
In-Reply-To: <1339318088-27126-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-10 at 11:48 +0300, Yuval Mintz wrote:
> This patch adds 2 new ethtool commands which can be
> used to manipulate network interfaces' support in
> EEE.
> 
> Output of 'get' has the following form:
> 
> 	EEE Settings for p2p1:
> 		EEE status: enabled - active
> 		Tx LPI: 1000 (us)
> 		Supported EEE link modes:  10000baseT/Full
> 		Advertised EEE link modes:  10000baseT/Full
> 		Link partner advertised EEE link modes:  10000baseT/Full
> 
> Thanks goes to Giuseppe Cavallaro for his original patch.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
[...]

Applied, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
