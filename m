From: Hyochang Nam <cannon@postech.ac.kr>
Subject: [Question] SMP for TCP/IP Stack
Date: Wed, 25 Sep 2002 11:27:31 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020925112731.A19934@toad.postech.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Can Linux Kernel 2.4.X handle two IP Packets at the same time
in a SMP machine which has two CPUs?
I have a SMP machine which equips two Intel Xeon CPUs and two
Intel Gigabit Network Cards. When I sent small IP Packets
to the machine, most of packets are dropped. When I watch 
CPU utlization with TOP program, only one CPU shows high value
but the other shows much low value, ie. 10% CPU utlization.
My test shows current IP Stack in Linux Kernel cannot provide 
SMP Processing properly. But, some articles said Linux Kernel 2.4
gives true SMP processing. What do you think my problem is?

Best regards,

Hyochang Nam
