From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 6/6][SCTP]: Extend /proc/net/sctp/snmp to provide more
	statistics.
Date: Mon, 17 Jul 2006 17:33:37 -0700
Message-ID: <1153182817.4282.49.camel@w-sridhar2.beaverton.ibm.com>
References: <1153182337.4282.48.camel@w-sridhar2.beaverton.ibm.com>
	 <20060717.173306.27784660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:13549 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751255AbWGRAgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:36:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0a9Aq023211
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:36:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0a98J278558
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:36:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0a9mo015296
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:36:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060717.173306.27784660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-17 at 17:33 -0700, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Mon, 17 Jul 2006 17:25:37 -0700
> 
> > [SCTP]: Extend /proc/net/sctp/snmp to provide more statistics.
> > 
> > This patch adds more statistics info under /proc/net/sctp/snmp
> > that should be useful for debugging. The additional events that
> > are counted now include timer expirations, retransmits, packet
> > and data chunk discards.
> 
> This is a feature patch, the feature window of 2.6.18 is closed.
> 
> The rest are bug fixes, so I'll apply those, thanks.

OK. I will resubmit this after 2.6.19 tree opens up.

Thanks
Sridhar

