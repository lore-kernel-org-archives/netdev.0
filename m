From: Ramesh Chaurasiya <rchaurasiya@cse.iitk.ac.in>
Subject: buffer overruns
Date: Sat, 24 Apr 2004 11:00:07 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.10.10404241055580.17512-100000@cseultra3.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
  Whenever I try to receive traffic at more than 500 Mbps, many packets
are being dropped as shown in ifconfig. There are many overruns and errors
in Rx packets details of ifconfig. I am using Intel PRO 1000 Gigabit NIC,
linux 2.4.20-8smp and dual processsor Xeon Machine with a 32bit/33 MHz PCI
bus. What does this error means. Am I dropping packets at
NIC/driver/kernel buffers/application socket? What new hardware should I
use to overcome this. I am using latest e1000 drivers compiled with NAPI
support. Please help me out.
Thanks,
Ramesh.
