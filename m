From: Rahul Hari <rahulhsaxena@gmail.com>
Subject: Tools for observing the effect of changes to sch_gred.c
Date: Fri, 10 Jun 2005 00:36:45 +0530
Message-ID: <4532f31705060912065c2917ef@mail.gmail.com>
Reply-To: rahul.hari@cse06.itbhu.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch, hadi@znyx.com, netdev@oss.sgi.com,
        diffserv-general-request@lists.sourceforge.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am a newbie to kernel programming and am making changes to
sch_gred.c so that the first virtual queue gets absolute priority
while dequeuing (starving the others) and the other virtual queues
dequeue the packets following a wrr algorithm.
 
Are there any tools that might help me in testing the effect of my
changes ... or i have to emulate the entire router,server,client setup
to test the effects.

Regards,
Rahul 
-- 
----------------------
"The fear you let build up in your mind is worse than the situation
that actually exists"
from "who moved my cheese"
---------------------------------------------------------------------------------
Rahul Hari
Senior Under Grad. Student,
Department of CSE,
ITBHU,
Varanasi.
Ph: +91-9845347020
rahul.hari@cse06.itbhu.org
------------------------------------------------------------------------------------------
