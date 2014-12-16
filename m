From: rapier <rapier@psc.edu>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 15:13:44 -0500
Message-ID: <54909278.6090806@psc.edu>
References: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>	<20141216.140919.44020047339373813.davem@davemloft.net>	<54908FAD.5060500@psc.edu> <20141216.150354.64901094367530710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:41111 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862AbaLPUNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 15:13:47 -0500
In-Reply-To: <20141216.150354.64901094367530710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/16/14, 3:03 PM, David Miller wrote:

> You shouldn't need to export any symbols.

As a point of clarification - is it acceptable to export symbols for use 
with in tree modules such as tcp_htcp? We are more than willing to do 
the work required to bring this in line with best practices.
