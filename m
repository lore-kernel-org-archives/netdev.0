From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: 2.4 and ip fragmentation question
Date: Wed, 31 Dec 2003 12:23:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231122325.77f19143.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

is ip fragmentation thought to work with multiple fragmented packets all with
same ID field, same source and destination address? Or can one consider this
situation as generally unsolvable and broken by application?

Regards,
Stephan
