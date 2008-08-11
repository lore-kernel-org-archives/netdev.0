From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 11 Aug 2008 14:56:01 -0700
Message-ID: <48A0B571.7010903@intel.com>
References: <48A086B6.2000901@linux-foundation.org>	<20080811.141501.01468546.davem@davemloft.net>	<48A0B037.501@linux-foundation.org> <20080811.145047.105665450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29990 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019AbYHKV6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 17:58:18 -0400
In-Reply-To: <20080811.145047.105665450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Mon, 11 Aug 2008 16:33:43 -0500
> 
>> Maybe what we are seeing is general bloat in kernel execution paths
>> due to the growth in complexity?
> 
> It could be, and any kind of analysis into this would be great.

perhaps Rick Jones who maintains netperf could enlighten us on some historic
numbers? he usually seems to be happy to prop up new netperf numbers :)


Auke
