From: Steve Modica <modica@sgi.com>
Subject: Linking interfaces to slots
Date: Fri, 03 Oct 2003 07:11:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7D675D.4000905@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

If one wanted to figure out which ethX was in which PCI slot on which 
bus, what would be the most acceptable mechanism?  The drivers have 
access to all this info, but then each driver would need some ioctl 
added. Is there some more generic place in the kernel that could be 
modified such that /proc/net/dev could hold this information?

Steve
