From: ananth@cse.iitk.ac.in
Subject: (no subject)
Date: Fri, 26 Mar 2004 20:27:18 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1080313038.406444cec9c60@webmail.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: sudheerv@cse.iitk.ac.in
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi, 

  I am using a DualProcessor Xeon 2.0GHz with 4 Intel PRO 1000 MT desktop
adapters using latest e1000 driver with NAPI enabled.(Linux 2.4.20-8 smp
kernel). When I tried to send packets through more than one interface at a high
speed (>200 Mbps) using raw sockets, my system is hanging. Is this a kernel bug?
Can anyone please suggest some method to achieve this. 

Thanks in advance,
Ananth. 
