From: "David S. Miller" <davem@redhat.com>
Subject: Re: gettime: Was (Re: Route cache performance under stress
Date: Thu, 12 Jun 2003 01:46:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.014611.32747925.davem@redhat.com>
References: <20030611120803.GB22720@wotan.suse.de>
	<20030611.203015.104061804.davem@redhat.com>
	<3EE81E89.1040004@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, hadi@shell.cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EE81E89.1040004@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Wed, 11 Jun 2003 23:32:41 -0700

   skb->rx_stamp = getCurTSC();

Thanks for mentioned this idea for the 10th time in
the past 2 days :-)
