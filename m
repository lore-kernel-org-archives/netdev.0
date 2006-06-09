From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2.6.17-rc6-mm1 ] net: RFC 3828-compliant UDP-Lite support
Date: Fri, 9 Jun 2006 10:36:41 +0100
Message-ID: <200606091036.42075.gerrit@erg.abdn.ac.uk>
References: <20060608.115331.71094388.davem@davemloft.net> <200606082109.34338.gerrit@erg.abdn.ac.uk> <20060608.151347.55505744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, alan@lxorguk.ukuu.org.uk, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60304 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S932346AbWFIJhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 05:37:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060608.151347.55505744.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Miller:
|  From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  Date: Thu, 8 Jun 2006 21:09:33 +0100
|  
|  > That is why I held back regarding the IPv6 port:
<snip> 
|  
|  It's not like an ipv6 port is such a big pile of work.
|  
I see the point and will port to v6 (have asked colleages for help). 
Until then, I will keep an up-to-date (-mm) patch in the tarball

http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/files/udplite_linux.tar.gz

This has applications as well. I would value any more input: the suggestion to 
use SOCK_DGRAM has already been integrated and proved a really good idea (much less 
to patch, cleaner code). Usually an update is there on the same day the new kernel 
comes out.
Thank you for your replies and comments, I will be back when the v6 side is ready.
