From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 16:52:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.165244.03972708.davem@redhat.com>
References: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
	<200209062356.g86Nu4Gk016944@tempest.prismnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tcw@tempest.prismnet.com
In-Reply-To: <200209062356.g86Nu4Gk016944@tempest.prismnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Troy Wilson <tcw@tempest.prismnet.com>
   Date: Fri, 6 Sep 2002 18:56:04 -0500 (CDT)

       4241408 segments retransmited

Is hw flow control being negotiated and enabled properly on the
gigabit interfaces?

There should be no reason for these kinds of retransmits to
happen.
