From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 11 Aug 2008 15:11:17 -0700
Message-ID: <48A0B905.20603@hp.com>
References: <48A086B6.2000901@linux-foundation.org>	<20080811.141501.01468546.davem@davemloft.net>	<48A0B037.501@linux-foundation.org>	<20080811.145047.105665450.davem@davemloft.net> <48A0B571.7010903@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:48550 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758389AbYHKWLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 18:11:20 -0400
In-Reply-To: <48A0B571.7010903@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> David Miller wrote:
> 
>>From: Christoph Lameter <cl@linux-foundation.org>
>>Date: Mon, 11 Aug 2008 16:33:43 -0500
>>
>>
>>>Maybe what we are seeing is general bloat in kernel execution paths
>>>due to the growth in complexity?
>>
>>It could be, and any kind of analysis into this would be great.
> 
> 
> perhaps Rick Jones who maintains netperf could enlighten us on some historic
> numbers? he usually seems to be happy to prop up new netperf numbers :)

While this is an excellent opening to talk about how netperf 
top-of-trunk can now emit keyword=value results easier (ostensibly) to 
put into a database then the regular or even CSV output formats, I 
cannot fully exploit it by pointing at a database of results :(

rick jones
