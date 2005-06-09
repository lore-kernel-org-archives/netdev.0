From: Andi Kleen <ak@muc.de>
Subject: Re: PROBLEM: High TCP latency
Date: Thu, 09 Jun 2005 15:47:53 +0200
Message-ID: <m1mzpzvdyu.fsf@muc.de>
References: <200506061135.09869.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hans Henrik Happe <hhh@imada.sdu.dk>
In-Reply-To: <200506061135.09869.hhh@imada.sdu.dk> (Hans Henrik Happe's
 message of "Mon, 6 Jun 2005 11:35:09 +0200")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Try echo 1 > /proc/sys/net/ipv4/tcp_low_latency

-Andi
