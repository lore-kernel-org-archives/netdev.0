From: Olaf Kirch <okir@lst.de>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sun, 24 Jun 2007 21:05:49 +0200
Message-ID: <200706242105.50759.okir@lst.de>
References: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com> <467C74BA.9060809@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	"C. Scott Ananian" <cscott@laptop.org>, netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:60014 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbXFXTGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 15:06:22 -0400
In-Reply-To: <467C74BA.9060809@simon.arlott.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 23 June 2007 03:17, Simon Arlott wrote:
> Because then it requires yet another network daemon, RA in 
> the kernel means there's no need for one to manage adding 
> auto-configured IP addresses... what's wrong with doing the 
> same for DNS?

Actually I think an integrated network autoconfiguration
daemon capable of doing DHCP, DHCP6, RDNSS, mDNS, you-name-it
would be a nice thing.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
