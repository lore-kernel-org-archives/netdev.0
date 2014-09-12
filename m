From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of
 pkt_type_offset
Date: Fri, 12 Sep 2014 16:13:37 -0400 (EDT)
Message-ID: <20140912.161337.1761990261895181530.davem@davemloft.net>
References: <CAHA+R7PrM3EwqD_7nT8odoCqmk7Q8cCdEcUn9Ck0MVPZKW3VXw@mail.gmail.com>
	<1410542240.2970.5.camel@localhost>
	<CAHA+R7N9voYjoWGyOvfR35mNc3bK_ZMO8X9OAp6Cy7uZr3E-Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	markos.chandras@imgtec.com, schwidefsky@de.ibm.com,
	dborkman@redhat.com, kda@linux-powerpc.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbaILUNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:13:43 -0400
In-Reply-To: <CAHA+R7N9voYjoWGyOvfR35mNc3bK_ZMO8X9OAp6Cy7uZr3E-Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 12 Sep 2014 10:47:54 -0700

> Don't worry, it is not a big deal at all, unless DaveM gets confused too.

DaveM is always confused.
