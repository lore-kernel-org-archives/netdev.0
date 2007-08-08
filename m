From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Wed, 08 Aug 2007 15:20:59 -0700 (PDT)
Message-ID: <20070808.152059.101495015.davem@davemloft.net>
References: <20070807.160651.98554604.davem@davemloft.net>
	<OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jgarzik@pobox.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rdreier@cisco.com,
	rusty@rustcorp.com.au, shemminger@linux-foundation.org
To: xma@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752679AbXHHWU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 18:20:59 -0400
In-Reply-To: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <xma@us.ibm.com>
Date: Wed, 8 Aug 2007 08:14:13 -0700

> Dave, could you please hold this portion of the patch for a moment. I will
> test this patch ASAP. According to our previous experience, this changes
> significant changes some IPoIB driver performance.

I reverted everything Roland had an issue with, I got tired of arguing
my position and doing all of the coding too.  He won.
