From: Meelis Roos <mroos@linux.ee>
Subject: netpoll warning in tulip
Date: Tue, 16 Mar 2004 12:36:02 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0403161235170.29946-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

FYI: with netpoll configured out, I get

  CC [M]  drivers/net/tulip/tulip_core.o
drivers/net/tulip/tulip_core.c:256: warning: `poll_tulip' declared `static' but never defined

-- 
Meelis Roos (mroos@linux.ee)
