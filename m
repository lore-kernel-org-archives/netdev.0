From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix bug with vlan strip in promsic mode
Date: Fri, 26 Mar 2010 21:00:52 -0700 (PDT)
Message-ID: <20100326.210052.169199791.davem@davemloft.net>
References: <20100325213428.8089.1879.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704Ab0C0EA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 00:00:28 -0400
In-Reply-To: <20100325213428.8089.1879.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Doesn't apply.

It depends upon the mc_list traversal conversions which are
absolutely not appropriate for net-2.6, and thus I only
applied to net-next-2.6
