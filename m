From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: AIM9 regression
Date: Tue, 23 Sep 2008 13:36:16 -0700
Message-ID: <20080923133616.7d51c953@extreme>
References: <48D93203.2050204@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38270 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbYIWUgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 16:36:24 -0400
In-Reply-To: <48D93203.2050204@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008 13:14:27 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:

> I just dont seem to be able to get 2.6.27 to behave in a speedy way network
> wise. Configured out various components (netfilter, etc etc) but I still keep
> getting these aim9 result against 2.6.22:
> 
> 47 misc_rtns_1  448038.00 430118.00  -17920.00 -4.00% Auxiliary Loops/second
> 48 dir_rtns_1   2412587.41 2723000.00  310412.59 12.87% Directory
> Operations/second
> 49 shell_rtns_1 364.30 345.80     -18.50 -5.08% Shell Scripts/second
> 50 shell_rtns_2 364.20 355.34      -8.86 -2.43% Shell Scripts/second
> 51 shell_rtns_3 363.30 353.60      -9.70 -2.67% Shell Scripts/second
> 52 series_1     6694290.00 6706690.00   12400.00  0.19% Series Evaluations/second
> 53 shared_memory 1042900.00 1080630.00   37730.00  3.62% Shared Memory
> Operations/second
> 54 tcp_test     352035.00 278442.00  -73593.00 -20.91% TCP/IP Messages/second
> 55 udp_test     640940.00 585570.00  -55370.00 -8.64% UDP/IP DataGrams/second
> 56 fifo_test    772440.00 932330.00  159890.00 20.70% FIFO Messages/second
> 57 stream_pipe  1222870.00 1230140.00    7270.00  0.59% Stream Pipe
> Messages/second
> 58 dgram_pipe   1143106.89 1152730.00    9623.11  0.84% DataGram Pipe
> Messages/second
> 59 pipe_cpy     867850.00 1065430.00  197580.00 22.77% Pipe Messages/second
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hardware configuration please?
