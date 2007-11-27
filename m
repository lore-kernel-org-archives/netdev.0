From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Tue, 27 Nov 2007 14:57:26 +0100
Message-ID: <474C2246.50205@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:41303 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097AbXK0N51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 08:57:27 -0500
In-Reply-To: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just wanted to ask whether there is a general interest in this patch.
If yes: great, how to proceed?
otherwise: please let me know why.

Thanks!




Ariane Keller wrote:
> Hi Stephen
> 
> Approximately a year ago we discussed an enhancement to netem,
> which we called "trace control for netem".
> 
> We obtain the value for the packet delay, drop, duplication and 
> corruption from a so called "trace file". The trace file may be obtained 
> by monitoring network traffic and thus enables us to emulate "real 
> world" network behavior.
> 
> Traces can ether be generated individually (we supply a set of tools to 
> do this) or can be downloaded from our homepage: http://tcn.hypert.net .
> 
> Since our last submission on 2006-12-15 we did some code clean up and 
> have created two new patches one against kernel 2.6.23.8 and one against 
> iproute2-2.6.23.
> To refer to our discussion from last year please have a look at messages 
> with subject "LARTC: trace control for netem".
> 
> We are looking forward for any comments, suggestions and instructions to 
> bring the trace enhancement to the kernel and to iproute2.
> 
> Thanks,
> Ariane
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
