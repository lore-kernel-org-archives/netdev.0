From: "Mala Anand" <manand@us.ibm.com>
Subject: IPV4 and IPV6 tcp_stream comparison
Date: Wed, 28 Aug 2002 16:52:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8FD51B6C.BAC47A60-ON87256C23.007274D4@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: "Bill Hartner" <bhartner@us.ibm.com>, "Venkata Jagana" <jagana@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org, usagi-users@linux-ipv6.org,
   linux-kernel@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I did a comparison test of IPV4 and IPV6 using 2.4.17
kernel for IPV4 and 2.4.17 kernel+USAGI-linux24-s20020415-2.4.17.diff
patch running netperf3, tcp_stream 1 adapter, 2 adapters
test on UNI, SMP kernels using a 2-way machine.
The test setup/results/profile can be found at:
http://www-124.ibm.com/developerworks/opensource/linuxperf/netperf/results/may_02/netperf3_ipv6_2.4.17resutls.htm


Regards,
    Mala


   Mala Anand
   IBM Linux Technology Center - Kernel Performance
   E-mail:manand@us.ibm.com
   http://www-124.ibm.com/developerworks/opensource/linuxperf
   http://www-124.ibm.com/developerworks/projects/linuxperf
   Phone:838-8088; Tie-line:678-8088
