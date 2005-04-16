From: linux lover <linux_lover2004@yahoo.com>
Subject: kfree_skb gives oops
Date: Sat, 16 Apr 2005 07:14:35 -0700 (PDT)
Message-ID: <20050416141435.60969.qmail@web52203.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
     I am checking some conditions in packet after IP
header is removed and based on that want network stack
to discard skbuff so i add it in ip_input.c . 
       But it gives oops message that 
Warning: kfree_skb passed an skb still on a list and
then prints oops 
       Please help how to do that and correct me to
use a way by which i will not face any kernel panic
message? 
Thanks in advance.
regards,
linux_lover.


		
__________________________________ 
Do you Yahoo!? 
Plan great trips with Yahoo! Travel: Now over 17,000 guides!
http://travel.yahoo.com/p-travelguide
