From: Jeff Garzik <jgarzik@pobox.com>
Subject: [NET] 2.6.x build warning
Date: Thu, 26 May 2005 15:09:15 -0400
Message-ID: <42961EDB.7000407@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


from current git tree:

net/ipv6/ip6_flowlabel.c: In function `ipv6_flowlabel_opt':
net/ipv6/ip6_flowlabel.c:540: warning: ignoring return value of 
`copy_to_user', declared with attribute warn_unused_result
