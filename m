From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igbvf: Remove unneeded pm_qos* calls
Date: Mon, 18 Oct 2010 08:12:17 -0700 (PDT)
Message-ID: <20101018.081217.112610920.davem@davemloft.net>
References: <20101016032547.1925.27290.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755564Ab0JRPLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 11:11:54 -0400
In-Reply-To: <20101016032547.1925.27290.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 15 Oct 2010 20:26:47 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Power Management Quality of Service is not supported or used by the VF
> driver.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
