From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbevf: Fix link speed display
Date: Tue, 27 Apr 2010 09:57:18 -0700 (PDT)
Message-ID: <20100427.095718.241930907.davem@davemloft.net>
References: <20100427103834.23338.22213.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751451Ab0D0Q5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 12:57:12 -0400
In-Reply-To: <20100427103834.23338.22213.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Not appropriate this late in the -RC series.

I don't see this in the regression list, and reported link speed being
incorrect is not a catastropic crash and/or failure.
