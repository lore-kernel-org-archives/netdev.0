From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] "Lots of unnecessary casts in drivers can be removed"
Date: Sun, 29 Feb 2004 15:05:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229150504.17f13e10.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Dave Jones wrote:
- Lots of unnecessary casts in drivers can be removed.

(from the KJ TODO list).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From: Carlo Perassi <carlo@linux.it>

Carlo sent patches to remove unneeded casts from 90 files.
Most of them are in drivers/net/ and will follow...
(not one per file but grouped into families).

[except for tokenring/ -- I have to rediff it.]

--
~Randy
