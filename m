From: "Zheng Jianping" <zjp@iscas.ac.cn>
Subject: how ipv6 support multicast routing
Date: Thu, 7 Nov 2002 14:21:52 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005a01c28625$f63a6810$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

We are developing IPv6 multicast routing protocol --PIM-SM. To support IPv6 multicast packet forwarding, Linux kernel need to be modified.  I am coding the file 'ip6_mroute.c' which is  derived from 'ipmr.c' in ipv4.
 
My question is how to modify the IPv6 code in the kernl to make 'ip6_mroute.c' works, i.e how to modify the files such as 'ip6/ip6_ouput.c', 'ip6/route.c' , etc.

I try to refrence to IPv4 code but it seems that the routing mechanism of IPv6 is something different from IPv4. So I get confused.

Could you give me some suggestion?

Thanks in advance!

Best Regards,
Zheng 



[[HTML alternate version deleted]]
