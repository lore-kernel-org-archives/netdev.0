From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Fri, 13 Oct 2006 14:50:53 -0700
Message-ID: <45300A3D.6010203@hp.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP> <452E69B2.4030306@hp.com>	<469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>	<452EC7B9.2030801@hp.com> <452F11E4.8050508@cosmosbay.com>	<452FC15D.7030902@hp.com> <452FF379.2080600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Schiller <mschiller@tdt.de>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:7358 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1030197AbWJMVu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 17:50:56 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <452FF379.2080600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> DATA payload could be included in the SYN packet. TCP specs allow 
>>> this AFAIK.
>> Yes, but it isn't supposed to be delivered until the 3-way handshake 
>> is complete right?
> Are you speaking of 20 years old BSD API ? :)

Nope - the bits in the RFCs about data not being delivered until the ISN's are 
validated.  I may have some of the timing a bit wrong though.

rick jones
