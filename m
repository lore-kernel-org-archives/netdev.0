From: Vasu <vasu@ee.iitb.ac.in>
Subject: injecting packets
Date: Tue, 16 Apr 2002 12:09:42 +0530
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.30.0204161203210.15280-100000@brahmi.ee.iitb.ac.in>
References: <Pine.LNX.4.44.0204151840060.10022-100000@havoc.ittc.ku.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
Date: Tue, 16 Apr 2002 12:09:42 +0530 (IST)
To: linux-net <linux-net@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44.0204151840060.10022-100000@havoc.ittc.ku.edu>
List-Id: netdev.vger.kernel.org


Hi.

I am trying to write a module that takes Ethernet packets from the user
domain, and injects it into the proper place ( which I think is the
sk_buffers ), so that to the IP, TCP layer, the packets look as if coming
from the Ethernet device. Can someone please suggest me which files to
look into, and which structs to handle, for getting this done. Also, I
want to do the reverse task, i.e. take some particular packets ( say which
come from a specific port ) from sk_buffers and send it to user space.

Please assume that this silly looking Rx/Tx has some importance :)

Regards.

Vasu.
III yr EE student.


