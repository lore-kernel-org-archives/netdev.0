From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: IPv6 RFC2292, 1883 and 2460 (was: RFC2292(bis))
Date: 20 May 2002 11:55:27 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1021888528.8107.25.camel@hoi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hi,

The RFC2292 based on the RFC1883 (and the Linux network (api/libc level)
implementation, too).
The RFC1883 obsolated by the RFC2460.
The Type0 routing header has changed between the two version: the S/L
bits were removed from it. (Changes 01.3) (And the address limit was
deleted, too)

Do the other implementations support the S/L bits?
(The current Netfilter implementation based on the RFC2460.)

regards

	kisza

-- 
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /-----Member of the BUTE-MIS-SEARCHlab------>
