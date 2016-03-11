From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 14:12:13 -0500
Message-ID: <20160311191213.GJ3383@oracle.com>
References: <20160311182949.GG3383@oracle.com>
 <20160311110927.5c559421@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16993 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcCKTMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:12:22 -0500
Content-Disposition: inline
In-Reply-To: <20160311110927.5c559421@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/11/16 11:09), Stephen Hemminger wrote:
> 
> Module parameters are a problem for distributions and should only be used
> as a last resort.

I was not aware of that- out of curiosity, what is the associated problem?

What would be the alternative recommendation in this case?

--Sowmini
