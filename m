From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/6] PS3: gelic: gelic updates for 2.6.25
Date: Tue, 22 Jan 2008 16:12:39 -0500
Message-ID: <20080122211239.GC3206@tuxdriver.com>
References: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux/PPC Development <linuxppc-dev@ozlabs.org>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3411 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834AbYAVVcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 16:32:19 -0500
Content-Disposition: inline
In-Reply-To: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2007 at 07:38:28PM +0900, Masakazu Mokuno wrote:

> Here is a set of updates for PS3 gelic network driver.
> This patch set requires other patches which were already submitted by
> Geert (http://marc.info/?l=linux-kernel&m=119626095605487).
> 
> 	[1] PS3: gelic: Fix the wrong dev_id passed
> 	[2] PS3: gelic: Add endianness macros
> 	[3] PS3: gelic: Code cleanup
> 	[4] PS3: gelic: Remove duplicated ethtool handers
> 	[5] PS3: gelic: Add support for port link status
> 	[6] PS3: gelic: Add support for dual network interface
> 
> This is also a set of prerequisite for new wireless driver for PS3, which
> I'll submit later. 

These seem to not have been applied, but I couldn't find any stated
reason.  Did they just get lost?  Withdrawn?

Will these be applied?  There is a wireless patch that depends on them.
If not, will the wireless portion be refactored to not require these
patches?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
