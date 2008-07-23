From: Jeff Garzik <jeff@garzik.org>
Subject: Re: someone broke qeth_l3_main.c
Date: Wed, 23 Jul 2008 12:28:42 -0400
Message-ID: <48875C3A.4020300@garzik.org>
References: <20080723012805.8a528347.akpm@linux-foundation.org> <1216802230.5517.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org
To: schwidefsky@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35003 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbYGWQ3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 12:29:22 -0400
In-Reply-To: <1216802230.5517.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Schwidefsky wrote:
> On Wed, 2008-07-23 at 01:28 -0700, Andrew Morton wrote:
>> drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_hard_start_xmit':
>> drivers/s390/net/qeth_l3_main.c:2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
>> drivers/s390/net/qeth_l3_main.c:2654: error: invalid type argument of '->'
> 
> Frank already sent a patch to Jeff to fix this. It should be in Jeffs
> queue now.

Should be upstream now...



