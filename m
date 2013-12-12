From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: Re: [PATCH ethtool 0/3] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 10:24:42 +0100
Message-ID: <52A980DA.7080605@linux.vnet.ibm.com>
References: <20131209063154.508075549@linux.vnet.ibm.com>
Reply-To: raspl@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:50680 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3LLJYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 04:24:49 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 09:24:47 -0000
In-Reply-To: <20131209063154.508075549@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.12.2013 07:31, schrieb raspl@linux.vnet.ibm.com:
> This patch series adds a new option to ethtool to display the adjacent switch
> port's attributes, as perceived by the NIC, e.g. through respective LLDP
> message exchanges.
> A patch for the qeth device driver provides a sample exploiter for the new
> functionality.
> 
> Best regards,
> Stefan Raspl
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Please ignore this stray patch series - the one posted 12/12 is the
real thing.

Regards
Stefan Raspl
