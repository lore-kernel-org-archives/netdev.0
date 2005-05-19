From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Thu, 19 May 2005 10:02:45 -0700
Message-ID: <428CC6B5.6070803@hp.com>
References: <428B6B72.5010407@hp.com>	<E1DYWM2-0004jM-00@gondolin.me.apana.org.au> <20050519122319.GH15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050519122319.GH15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I agree, however defining a value of 600 system wide is horrible for
> all hosts that behave "correctly". So what we could do is take probes
> of the id distribution and define the threshold on a per peer scope.

Why would 600 penalize a host behaving "correctly?"  I mean, what are the 
chances of a datagram's being reassembled, if 600 subsent datagrams have arrived 
from that same host?

rick
