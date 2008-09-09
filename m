From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH next] r8169: select MII in Kconfig
Date: Wed, 10 Sep 2008 00:32:28 +0200
Message-ID: <20080909223228.GB17052@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0809082145440.2050@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hugh Dickins <hugh@veritas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46748 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753511AbYIIWcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 18:32:39 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0809082145440.2050@blonde.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hugh Dickins <hugh@veritas.com> :
> drivers/built-in.o: In function `rtl8169_gset_xmii':
> r8169.c:(.text+0x82259): undefined reference to `mii_ethtool_gset'
> suggests that R8169 now needs to select MII.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Ack. I'll add it to the r8169 branch. It's rebase season :o)

-- 
Ueimor
