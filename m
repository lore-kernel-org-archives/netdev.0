From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 2.6.24] pasemi_mac: Fix reuse of free'd skb
Date: Tue, 04 Dec 2007 18:12:17 +0000
Message-ID: <1196791937.13978.362.camel@pmac.infradead.org>
References: <20071204033414.GA13616@lixom.net>
	 <1196791478.13978.359.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	ranger@gentoo.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36409 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbXLDSMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 13:12:22 -0500
In-Reply-To: <1196791478.13978.359.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2007-12-04 at 18:04 +0000, David Woodhouse wrote:
> Oops: Exception in kernel mode, sig: 5 [#1]                                     
> nfs: server pmac not responding, still trying         

Oops, sorry. That was meant to be just to Olof. And it helps if I'm
actually running the kernel in which his patch is applied, too...

-- 
dwmw2

