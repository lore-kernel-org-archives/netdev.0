From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] e1000e: save skb counts in TX to avoid cache misses
Date: Fri, 23 Apr 2010 23:30:52 -0700 (PDT)
Message-ID: <20100423.233052.226770500.davem@davemloft.net>
References: <alpine.DEB.1.00.1004231719050.16806@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750729Ab0DXGar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 02:30:47 -0400
In-Reply-To: <alpine.DEB.1.00.1004231719050.16806@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Intel folks, please integrate Tom's patches.

Tom, please always CC: the developers listed in MAINTAINERS
for the driver you are submitting patches to.

Thanks.
