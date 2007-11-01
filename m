From: David Miller <davem@davemloft.net>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 14:59:56 -0700 (PDT)
Message-ID: <20071101.145956.63020380.davem@davemloft.net>
References: <4729EAFF.9050606@candelatech.com>
	<18218.18134.353553.189622@zeus.sw.starentnetworks.com>
	<472A49BD.6000802@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	greearb@candelatech.com, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753143AbXKAV75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:59:57 -0400
In-Reply-To: <472A49BD.6000802@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 01 Nov 2007 14:48:45 -0700

> One could I suppose try to ammend the information passed to allow
> tcpdump to say "oh, this was a tx packet on the same machine on
> which I am tracing so don't worry about checksum mismatch"

We do this already!

