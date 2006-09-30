From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 5/6]: powerpc/cell spidernet ethtool -i version number
Date: Sat, 30 Sep 2006 12:35:15 +0200
Message-ID: <200609301235.15794.arnd@arndb.de>
References: <20060929230552.GG6433@austin.ibm.com> <20060929232625.GM6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@osdl.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:5102 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750781AbWI3KfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 06:35:15 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060929232625.GM6433@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Saturday 30 September 2006 01:26 schrieb Linas Vepstas:
> This patch moves transmit queue cleanup code out of the
> interrupt context, and into the NAPI polling routine.
>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: James K Lewis <jklewis@us.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

The subject of this mail should be "spidernet: use NAPI poll for
TX interrupts", otherwise

Acked-by: Arnd Bergmann <arnd@arndb.de>
