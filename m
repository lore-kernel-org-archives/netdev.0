From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Wed, 8 Aug 2007 16:23:08 -0700
Message-ID: <OF88AC1611.F8A1A279-ON87257331.008011B7-88257331.00804588@us.ibm.com>
References: <20070808.152059.101495015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: hadi@cyberus.ca, jgarzik@pobox.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rdreier@cisco.com,
	rusty@rustcorp.com.au, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42002 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232AbXHHXXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 19:23:23 -0400
In-Reply-To: <20070808.152059.101495015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

> I reverted everything Roland had an issue with, I got tired of arguing
> my position and doing all of the coding too.  He won.
Thanks. I think the reschedule in the IPoIB poll should maintain fairness.

Shirley
