From: Chase Douglas <cndougla@purdue.edu>
Subject: Beginner's information on 2.6 implementation of networking
Date: Wed,  6 Apr 2005 10:37:30 -0500
Message-ID: <1112801850.4254023a192c5@webmail.purdue.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, cndougla@purdue.edu
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have an idea for linux networking at the level of manipulation of how sk_buffs
are used. However, I do not know where in the linux kernel code to begin looking
for where sk_buffs are manipulated. I was wondering if there were any good
resources on the 2.6 implementation of the tcp/ip protocol. I have found a few
documents on 2.2 and 2.4, but many of the functions listed do not seem to be
present in the 2.6 kernel. Even if I could have a list of function calls from
send to receive using the tcp/ip protocol, it would help a lot.

Thank you
