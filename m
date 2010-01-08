From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/5] e1000e: call pci_save_state() after
 pci_restore_state()
Date: Thu, 07 Jan 2010 23:52:40 -0800 (PST)
Message-ID: <20100107.235240.173918660.davem@davemloft.net>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715Ab0AHHwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 02:52:33 -0500
In-Reply-To: <20100108023033.31476.4034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Aren't the fragment overrun patches for e1000 and e1000e 1,000 times
more important that thumb twiddling fixes like these? :-(
