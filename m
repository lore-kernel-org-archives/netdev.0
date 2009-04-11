From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] Be explict with what we are !'ing in
 ixgbe_sfp_config_module_task()
Date: Sat, 11 Apr 2009 02:51:35 -0700 (PDT)
Message-ID: <20090411.025135.252208257.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
	<20090410082910.14372.22207.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, tony@bakeyournoodle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757666AbZDKJvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:51:44 -0400
In-Reply-To: <20090410082910.14372.22207.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:29:10 -0700

> GCC warns:
> drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_sfp_config_module_task':
> drivers/net/ixgbe/ixgbe_main.c:3920: warning: suggest parantheses around
> operand of '!' or change '&' to '&&' or '!' to '~'
> 
> Which I think is right.  Bracket to remove ambiguity.
> 
> Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
