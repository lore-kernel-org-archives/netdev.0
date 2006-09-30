From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/6]: powerpc/cell spidernet stop error printing patch.
Date: Sat, 30 Sep 2006 12:32:04 +0200
Message-ID: <200609301232.04585.arnd@arndb.de>
References: <20060929230552.GG6433@austin.ibm.com> <20060929231922.GK6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, jeff@garzik.org,
	akpm@osdl.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:20172 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750794AbWI3KfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 06:35:20 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060929231922.GK6433@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Saturday 30 September 2006 01:19 schrieb Linas Vepstas:
> Turn off mis-interpretation of the queue-empty interrupt
> status bit as an error. This bit is set as a part of
> the previous low-watermark patch.
>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Signed-off-by: James K Lewis <jklewis@us.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

Acked-by: Arnd Bergmann <arnd@arndb.de>
