From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Move hardware headers for decaped packets
Date: Fri, 13 Feb 2004 23:10:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213231027.1e483332.davem@redhat.com>
References: <20030925121131.GA17968@gondor.apana.org.au>
	<200309251228.QAA11650@yakov.inr.ac.ru>
	<20030925124102.GA18188@gondor.apana.org.au>
	<20031207090205.GA2358@gondor.apana.org.au>
	<20031207014714.03e79cd2.davem@redhat.com>
	<20031207095527.GA2767@gondor.apana.org.au>
	<20031207165516.1edfde10.davem@redhat.com>
	<20040214035534.GA25965@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040214035534.GA25965@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Feb 2004 14:55:34 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Looks like I've forgotten about this mac moving patch.  Here it is again.
> 
> Just to recap, this moves the hardware header so that it appears
> next to the payload for AF_PACKET sockets.

Queued for 2.6.4-pre1, thanks Herbert.
