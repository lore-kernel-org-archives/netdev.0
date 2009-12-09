From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] e1000e: minor correction to name of bit in
 CTRL_EXT register
Date: Tue, 08 Dec 2009 20:10:54 -0800 (PST)
Message-ID: <20091208.201054.201657960.davem@davemloft.net>
References: <20091208172725.19741.25809.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37895
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756648AbZLIEKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:10:47 -0500
In-Reply-To: <20091208172725.19741.25809.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 08 Dec 2009 09:27:41 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Bit 7 in the CTRL_REG register is actually the Software Definable Pin 3,
> not the Software Definable Pin 7.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
