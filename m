From: Horms <horms@verge.net.au>
Subject: IPVS Sysctl Variables
Date: Fri, 30 Jun 2006 15:19:41 +0900
Message-ID: <20060630061940.GA31956@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:52716 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751145AbWF3HPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 03:15:32 -0400
To: NetDev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

there are quite a number of entries under /proc/sys/net/ipv4/vs,
I swear that they were documented in Documentation/networking/
at some stage, but perhaps I am dreaming.

In any case, if I clean up the information at the following URL (which a
probably complete list of what the options are and what they do, you don't
have to check if you don't want to), is it appropriate for inclusion in
Documentation/networking/, and if so, should it be in ip-sysctl.txt, or
elsewhere?

http://www.linuxvirtualserver.org/docs/sysctl.html

-- 
Horms                                           
H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/en/

