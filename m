From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000/e1000: fix compile warning
Date: Tue, 14 Apr 2009 16:38:58 -0700 (PDT)
Message-ID: <20090414.163858.169457795.davem@davemloft.net>
References: <20090414144249.9091.15839.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752274AbZDNXjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 19:39:08 -0400
In-Reply-To: <20090414144249.9091.15839.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 14 Apr 2009 07:42:49 -0700

> e1000/e1000e compile report a possible unused variable, fix
> that for now.  Shortly after this a small refactor and bug
> fix will follow in the same code.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
