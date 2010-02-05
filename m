From: Jasper Spaans <spaans@fox-it.com>
Subject: Re: [RFC 0/4] bond hashing revised
Date: Fri, 5 Feb 2010 09:40:17 +0000
Message-ID: <4B6BE781.7070107@fox-it.com>
References: <20100204171118.917737392@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:31151 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0BEJkT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 04:40:19 -0500
In-Reply-To: <20100204171118.917737392@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/10 17:11, Stephen Hemminger wrote:
> These have not been tested yet. I need to try them with some
> different flows/hardware to validate.
>   
Glancing over these patches, all four of them look fine to me.

The only thing missing is some documentation in
Documentation/networking/bonding.txt (I have no idea what multiqueue is
supposed to do, but if you tell me I'll volunteer).

Cheers,
Jasper

-- 
Ir. Jasper Spaans
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624


