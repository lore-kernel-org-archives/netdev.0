From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/5] igb: update driver to use setup_timer
 function
Date: Sat, 21 Mar 2009 16:57:23 -0700 (PDT)
Message-ID: <20090321.165723.233452070.davem@davemloft.net>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
	<20090320101708.17663.50584.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754396AbZCUX5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 19:57:36 -0400
In-Reply-To: <20090320101708.17663.50584.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Mar 2009 03:17:08 -0700

> igb was previously setting up all of the timer members itself.  It is
> easier to just call setup_timer and reduce the calls to one line.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
