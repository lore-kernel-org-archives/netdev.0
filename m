From: Meelis Roos <mroos@linux.ee>
Subject: 2.6.10-rc2: still no ipv6 link-local addresses
Date: Mon, 15 Nov 2004 14:36:56 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0411151159230.3321@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I tried 2.6.10-rc2 and it still does not give lipv6 link-local address 
to Ethernet interfaces (I tried NICs with e100 and 8139too drivers).

This is broken since 2.6.9.

-- 
Meelis Roos (mroos@linux.ee)
