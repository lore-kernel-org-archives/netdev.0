From: Nawab Hasan <hnawab@in.ibm.com>
Subject: Jumbogram!-checksum!
Date: Thu, 22 Apr 2004 19:13:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8B74601F.5DF50E80-ON65256E7E.00324B3F@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Hi,
in Ipv6 the jumbogram packet could be as large as  4294967296 octet.It will
be overhead for calculating the checksum
for TCP and UDP(pseudo header).It will in turn degrade the performance if
not what are other methods for getting the
integrate ipv6 packet over ipv6 node.Could someone help me out on this
issue?

Nawab
