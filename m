From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/5] igb: remove IGB_DESC_UNUSED since it is
 better handled by a function call
Date: Sat, 21 Mar 2009 16:57:16 -0700 (PDT)
Message-ID: <20090321.165716.229790037.davem@davemloft.net>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
	<20090320101650.17663.62516.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752144AbZCUX53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 19:57:29 -0400
In-Reply-To: <20090320101650.17663.62516.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Mar 2009 03:16:50 -0700

> This patch removes IGB_DESC_UNUSED and replaces it with a function call
> instead in order to cleanup some of the ugliness introduced by the macro.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
