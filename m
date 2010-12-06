From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] ixgbe: fix enum type mismatch on
 disable laser
Date: Mon, 06 Dec 2010 13:21:29 -0800 (PST)
Message-ID: <20101206.132129.183052429.davem@davemloft.net>
References: <20101203232218.21869.62349.stgit@localhost.localdomain>
	<20101203232351.21869.98417.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40177
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753796Ab0LFVVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:21:02 -0500
In-Reply-To: <20101203232351.21869.98417.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 03 Dec 2010 15:24:05 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Fixes a recent bug on the patch (c6ecf39a10ceec3e97096e2a8d3eadcecd593422)
> that disabled the laser on ifconfig down.  Compilers were seeing a enum
> mismatch.
> 
> Signed-off-by Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
