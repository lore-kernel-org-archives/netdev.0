From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/8] 2.4.26-bk1 pcnet32.c
Date: Tue, 20 Apr 2004 13:12:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404202012.i3KKC9C13567@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patches to 2.4.26-bk1 to bring the 2.4 driver
to the same level as 2.6.6 (and a little beyond).

[PATCH 1/8 2.4.26-bk1] pcnet32 whitespace only changes
[PATCH 2/8 2.4.26-bk1] pcnet32 add 79C976 support
[PATCH 3/8 2.4.26-bk1] pcnet32 all printk under netif_msg 
[PATCH 4/8 2.4.26-bk1] pcnet32 correct name display
[PATCH 5/8 2.4.26-bk1] pcnet32 add led blink capability
[PATCH 6/8 2.4.26-bk1] pcnet32 transmit performance fix
[PATCH 7/8 2.4.26-bk1] pcnet32 add register dump capability
[PATCH 8/8 2.4.26-bk1] pcnet32 timer to free tx skbs for 79C971/972 

-- 
Don Fry
brazilnut@us.ibm.com
