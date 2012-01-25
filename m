From: Ganesh Reddy K <ganeshreddyk@gmail.com>
Subject: iproute2-2.6.38 + oif argument error
Date: Thu, 26 Jan 2012 01:14:34 +0530
Message-ID: <CA+h4rtFMtprNyW2GH601TY9gBY1JTWK+Wktka-RzD8MQogK+zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ganesh Reddy <ganeshreddyk@gmail.com>,
	ganeshreddy <ganeshreddy@freescale.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am trying to exercise 'ip rules'  command with some configuration on
 a PowerPC Processor. Version is iproute2-2.6.38


I tried "ip rule add oif eth1 table 100"
It  resulted with  error message "RTNETLINK answers: Invalid argument".

Can anybody tried this.

It is shown in the ip rule help all the possible options . Few of them
are iif, oif.    iif option is working . No issue observed.   oif
option is causing error.


Can you please share any patch fixes to proceed further ?

Thanks,
Ganesh
