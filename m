From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Mon, 20 Sep 2004 10:46:08 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409201036270.1288@u.domain.uli>
References: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
 <20040912170323.65eadc38.davem@davemloft.net> <20040914071241.GM8434@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040914071241.GM8434@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 14 Sep 2004, Harald Welte wrote:

> I agree with the change (although I didn't test it here on my systems so
> far).  However, as indicated in private mail to Julian, the change
> should be made consistent over all helpers.

	No private mail received yet. But I agree, it should work
for other helpers, eg. similar change can go in do_bindings instead.

Regards

--
Julian Anastasov <ja@ssi.bg>
