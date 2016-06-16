From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] sfc: RX VLAN filtering
Date: Wed, 15 Jun 2016 22:26:43 -0700 (PDT)
Message-ID: <20160615.222643.265710629592463430.davem@davemloft.net>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbcFPF0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:26:44 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 15 Jun 2016 17:39:56 +0100

> Adds support for VLAN-qualified receive filters on EF10 hardware.
> This is needed when running as a guest if the hypervisor has enabled
> vfs-vlan-restrict, in which case the firmware rejects filters not qualified
> with VLAN 0.

Series applied, thank you.
