From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipsec 2.5.70 trouble
Date: Thu, 29 May 2003 16:47:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.164722.116357594.davem@redhat.com>
References: <1054235155.596.9.camel@simulacron>
	<20030529.141410.85405194.davem@redhat.com>
	<1054251582.2598.57.camel@simulacron>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: aj@dungeon.inka.de
In-Reply-To: <1054251582.2598.57.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andreas Jellinghaus <aj@dungeon.inka.de>
   Date: 30 May 2003 01:39:43 +0200
   
   Can I do anything about this?

The connection looks fine, 212.202.202.151 simply isn't sending any
data back.  Maybe dropped PMTU messages, can you get a trace from the
other end of the IPSEC tunnel?
