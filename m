From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/3] r8169:Fix typo in setting RTL8168EP and
 RTL8168H D3cold PFM mode
Date: Tue, 29 Dec 2015 23:28:24 +0100
Message-ID: <20151229222824.GA7626@electric-eye.fr.zoreil.com>
References: <1451398419-4816-1-git-send-email-hau@realtek.com>
 <1451398419-4816-2-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39855 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbL2W2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 17:28:33 -0500
Content-Disposition: inline
In-Reply-To: <1451398419-4816-2-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chunhao Lin <hau@realtek.com> :
> The register for setting D3code PFM mode is  MISC_1, not DLLPR.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

Reviewed-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
