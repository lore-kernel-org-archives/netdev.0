From: Rick Jones <rick.jones2@hp.com>
Subject: on the wire behaviour of TSO on/off is supposed to be the same yes?
Date: Fri, 21 Jan 2005 11:01:01 -0800
Message-ID: <41F1516D.5010101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is it indeed supposed to be the case that the on the wire behaviour of TCP with 
TSO on/off is supposed to be the same?  I'm seeing some cases (netperf 
TCP_STREAM 2.6.10 sending to HP-UX 11.23) where the throughput differences are 
 >= 10 MB/s on an e1000 card (TSO being slower).  I've got lots of netperf and 
tcpdump but thought I'd ask first before dumping it onto the list.  Actually, 
i'll probably have to put it up on the net somewhere since it is O(200MB) in 
total (although I have a smaller point example).

sincerely,

rick jones
