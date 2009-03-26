From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/4] e1000e: commonize tx cleanup routine to
 match e1000 & igb
Date: Thu, 26 Mar 2009 01:12:14 -0700 (PDT)
Message-ID: <20090326.011214.38081385.davem@davemloft.net>
References: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756154AbZCZIM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:12:27 -0400
In-Reply-To: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 01:05:03 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change updates the e1000e tx cleanup routine to more closely match
> what already exists in igb and e1000.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
