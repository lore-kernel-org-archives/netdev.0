From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2]:  powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 16:34:31 -0400
Message-ID: <44E38157.4070805@garzik.org>
References: <20060811170337.GH10638@austin.ibm.com> <20060816161856.GD20551@austin.ibm.com> <44E34825.2020105@garzik.org> <20060816203043.GJ20551@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:28042 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750843AbWHPUei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 16:34:38 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060816203043.GJ20551@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> I was under the impression that NAPI was for the receive side only.

That depends on the driver implementation.

	Jeff


