From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [-mm PATCH][0/4] net: signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 23:29:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506152234040.3842__24793.018870014$1118870641$gmane$org@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>, Ross Biro <ross.biro@gmail.com>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

As promised, my previous net/ipv4/raw.c signed/unsigned cleanup patch in 
little bits with explanations.

This series of patches cleans up signed versus unsigned variable use in 
net/ipv4/raw.c .
The patches are created incrementally on top of each other but will 
probably each apply (with a little fuzz) on their own out of order.

Please keep me on CC if you reply since I'm not subscribed to both lists 
the patches are send to (only to lkml).


-- 
Jesper Juhl 
