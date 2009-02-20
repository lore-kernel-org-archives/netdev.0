From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 5/5] igb: this patch addes the sr-iov
 enablement option via num_vfs parameter
Date: Fri, 20 Feb 2009 00:23:48 -0800 (PST)
Message-ID: <20090220.002348.41226704.davem@davemloft.net>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
	<20090220044030.29650.14066.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, yu.zhao@intel.com,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757180AbZBTIYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:24:07 -0500
In-Reply-To: <20090220044030.29650.14066.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Feb 2009 20:40:30 -0800

> This code adds a module parameter called num_vfs which defines if the
> driver should attempt to use sr-iov and if so how many VFs should be
> enabled.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Also applied, thanks a lot.
