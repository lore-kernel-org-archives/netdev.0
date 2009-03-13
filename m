From: David Miller <davem@davemloft.net>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Fri, 13 Mar 2009 14:54:48 -0700 (PDT)
Message-ID: <20090313.145448.113437230.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365F69CA4280@rrsmsx501.amr.corp.intel.com>
	<20090313115245.GA31949@gondor.apana.org.au>
	<EA929A9653AAE14F841771FB1DE5A1365F69E95C03@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, alexander.h.duyck@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753817AbZCMVzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:55:02 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F69E95C03@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Fri, 13 Mar 2009 15:53:47 -0600

> With this patch the stress test has been going for more than 4 hours
> now (compared to minutes until panic before). I will leave the test
> running over the weekend, but at least for now looks like it's
> fixed.

Thanks for testing.

Herbert, want me to toss this into net-2.6 now?
