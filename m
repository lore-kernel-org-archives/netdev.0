From: David Miller <davem@davemloft.net>
Subject: Re: vxge: Update driver_config->vpath_per_dev for each function in
 probe.
Date: Mon, 05 Oct 2009 02:32:19 -0700 (PDT)
Message-ID: <20091005.023219.45309053.davem@davemloft.net>
References: <Pine.GSO.4.10.10910050506150.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758198AbZJEJcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:32:24 -0400
In-Reply-To: <Pine.GSO.4.10.10910050506150.2346-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 05:06:56 -0400 (EDT)

> - Update driver_config->vpath_per_dev for each function in probe.
> 
> - vpath_per_device specifies number of vpaths supported for each function/device. The
>   current code was updating vpath_per_device only for physical device, however this has
>   to be updated for each function also in case of a MF(Multi function) device.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

You keep posting this patch twice.

Once without the proper "[PATCH 2/9]" indication in the subject
heading, and once with it there.

Please sort out your patch set, there is something wrong with
what you're submitting for this.
