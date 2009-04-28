From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/6] igb: reconfigure mailbox timeout logic
Date: Tue, 28 Apr 2009 01:54:21 -0700 (PDT)
Message-ID: <20090428.015421.48309135.davem@davemloft.net>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754756AbZD1Iy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:54:27 -0400
In-Reply-To: <20090428083445.32417.77682.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:34:54 -0700

> This change updates the timeout logic so that it is not possible to have a
> sucessful check for message and still return an error if countdown = 0.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Reported-by: Juha Leppanen <juha_motorsportscom@luukku.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
