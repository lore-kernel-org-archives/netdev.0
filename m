From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 4/4]: powerpc/cell spidernet ethtool -i version number info.
Date: Fri, 11 Aug 2006 13:00:13 -0500
Message-ID: <20060811180013.GB6550@pb15.lixom.net>
References: <20060811170337.GH10638@austin.ibm.com> <20060811171117.GL10638@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:64455 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S1750910AbWHKSEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 14:04:11 -0400
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060811171117.GL10638@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2006 at 12:11:17PM -0500, Linas Vepstas wrote:

> This patch adds version information as reported by 
> ethtool -i to the Spidernet driver.

Why does a driver that's in the mainline kernel need to have a version
number besides the kernel version?

I can understand it for drivers like e1000 that Intel maintain outside
of the kernel as well. But spidernet is a fully mainline maintained
driver, right?


-Olof
