From: Dax Kelson <dax@gurulabs.com>
Subject: Memory usage for ip_conntrack
Date: 18 Jul 2003 14:07:29 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058558848.2674.88.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm teaching a Linux class and the book says "Using ip_conntrack will
use much more memory".

A student asked me how much is "much".

So on a 2.4.20+  how much memory does it take to track the state of a
connection?

If I echo 102400 > /proc/sys/net/ipv4/ip_conntrack_max, what is my worst
case memory usage?

TIA,

Dax Kelson
