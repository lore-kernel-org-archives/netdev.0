From: Stephen Hemminger <shemminger@osdl.org>
Subject: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 11:03:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096481023.8636.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is lots of stuff going on that has a potential to make things less
stable. How about routing any future TCP, fib, statistics, stuff through
Andrew's tree and not directly to Linus. That way we have some buffer
and can stablize some more. Alternatively, Dave you could publize your
staging area some more.
