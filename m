From: satya srikanth <satyasrikanth2001@yahoo.com>
Subject: Xeon smp performance
Date: Mon, 8 Mar 2004 05:23:54 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308132354.77437.qmail@web21101.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
   I am writing a simple sniffer program that will
sniff packets in a gigabit network. I am using a dual
processor 2 GHz Xeon processor with one Intel Pro-1000
desktop adapter, running 2.4.20-8smp linux.=20
   I found that for all packet sizes and network
bandwidth, 2.4.20-8 uniprocessor version that uses
only one processor is performing better than
2.4.20-8smp using two processors in terms of packet
drops and CPU utilization. Each processor in smp is
utilizing more CPU than one processor in uni-processor
case. What is the reason for this peculiar behaviour?
Is it possible for me to use the power of second
processor without adding more NICs. Will I face
similar problems with 2.6 also? Anybody familiar with
these please help me out.

TIA
Satya Srikanth

__________________________________
Do you Yahoo!?
Yahoo! Search - Find what you=92re looking for faster
http://search.yahoo.com
