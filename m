From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/6]: powerpc/cell spidernet burst alignment patch
Date: Sat, 19 Aug 2006 00:51:01 +0200
Message-ID: <200608190051.03105.arnd@arndb.de>
References: <20060818220700.GG26889@austin.ibm.com> <20060818222038.GH26889@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org,
	ens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:32472 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751494AbWHRWvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 18:51:18 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060818222038.GH26889@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 19 August 2006 00:20, Linas Vepstas wrote:
> This patch increases the Burst Address alignment from 64 to 1024 in the
> Spidernet driver. This improves transmit performance for arge packets
> from about 100Mbps to 300-400Mbps.

Acked-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>
