From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 13:42:10 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029024210.01A8912C8D5@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210231031540.26788-100000@netcore.fi> (at Wed, 23 Oct 2002 10:36:19 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> Does Bind 9.2.1 work this so that it can receive packets, when IPv6 is
> also enabled, from IPv4 addresses using TCP without
> 'match-mapped-addresses yes', or is that a separate problem?

Bind9 trys to bind :: and all ipv4 addresses on the node.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
