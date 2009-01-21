From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] igb: make certain to power on optics for 82576
 fiber nics
Date: Wed, 21 Jan 2009 14:43:04 -0800 (PST)
Message-ID: <20090121.144304.215429349.davem@davemloft.net>
References: <20090121083329.538.67223.stgit@lost.foo-projects.org>
	<20090121083348.538.52922.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753588AbZAUWnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:43:02 -0500
In-Reply-To: <20090121083348.538.52922.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 21 Jan 2009 00:33:48 -0800

> It appears that a step was missed in the initialization of 82576 fiber nics
> that resulted in it not powering on the optics.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

