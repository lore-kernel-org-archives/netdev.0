From: Michael Kerrisk <mtk.manpages@googlemail.com>
Subject: Undocumented IPv6 options
Date: Mon, 15 Oct 2007 08:54:49 +0200
Message-ID: <47130EB9.3090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-man@vger.kernel.org,
	Andrew McDonald <andrew@mcdonald.org.uk>,
	linux-net@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:2941 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618AbXJOG5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 02:57:53 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1177609nfb
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 23:57:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello netdev,

Andrew McDonald kindly fixed the description of IPV6_ROUTER_ALERT in the
ipv7.7 man page.  As long as we're on the topic, I'll point out that the
following IPV6 options (and possibly others) are still not documented on
that page:

IPV6_CHECKSUM
IPV6_JOIN_ANYCAST
IPV6_LEAVE_ANYCAST
IPV6_V6ONLY
IPV6_RECVPKTINFO
IPV6_2292PKTINFO

Can anyone help with documenting any of these please?

Cheers,

Michael
-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

Want to help with man page maintenance?  Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.


