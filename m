From: Amit Kucheria <amitk@ittc.ku.edu>
Subject: dev->hard_start_xmit non-reentrant?
Date: Mon, 15 Apr 2002 18:46:44 -0500 (CDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204151846020.10038-100000@havoc.ittc.ku.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Is it guaranteed by the higher layers that dev->hard_start_xmit is 
non-reentrant?
I saw a comment to that effect in loopback.c and wondered if this was true 
for all devices.

TIA.
ciao,
Amit

-- 
I'm an angel!!! Honest!
The horns are just there to hold the halo up straight.
^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^
                  Amit Kucheria
          EECS Grad. Research Assistant
         University of Kansas @ Lawrence
   (R)+1-(785)-830 8521 ||| (O)+1-(785)-864 7774
____________________________________________________


