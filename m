From: Baruch Even <baruch@ev-en.org>
Subject: [TCP 0/4] H-TCP patches on top of Stephens cc framework
Date: Fri,  6 May 2005 20:37:29 +0300 (IDT)
Message-ID: <20050506173729.20140.93205.37072@galon.ev-en.org>
Cc: netdev@oss.sgi.com, Baruch Even <baruch@ev-en.org>,
        Douglas Leith <doug.leith@nuim.ie>,
        "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a first post of the H-TCP framework on top of Stephens congestion
control framework. Hopefully the use of the framework will make it easier to
understand the logic of the H-TCP algorithm. It definitely helped me :-)

The code is licensed under the GNU GPL v2, and according to that we know this
gives an implicit patent license to users of this code. An explicit licensing
to OSDL for the purpose of sub-licensing is in the works to alleviate any fear.

Baruch
