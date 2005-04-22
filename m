From: Chris Friesen <cfriesen@nortel.com>
Subject: 2.6.9 BUG in tcp_transmit_skb at net/ipv4/tcp_output.c
Date: Fri, 22 Apr 2005 09:48:19 -0600
Message-ID: <42691CC3.7000108@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've got an error report for a problem with 2.6.9 networking.  We seem 
to be intermittently hitting the above error after at least a couple 
hours or so of runtime, sometimes it takes up to 14 hrs or so, sometimes 
it doesn't happen.  Network load is minimal.

Anyone have any ideas on what this might be or how I can track it down? 
  Has it been fixed in later releases?

Thanks for any help you can give,

Chris
