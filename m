From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 09 Mar 2004 10:56:52 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <404E1374.5050600@us.ibm.com>
References: <20040309180331.GC11604@wotan.suse.de>	<Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu> <20040309102206.33c1720c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, Andi Kleen <ak@suse.de>,
	linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040309102206.33c1720c@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Every case I tested has vegas faster than the default reno.  It is especially
> noticeable over the DSL.  The current implementation is not ready to be turned
> on by default though.

Stephen, just a question regarding your testing.
(To save me some effort ;-)). What tests did you
run, which testcases, and if it wasn't some standard
benchmark, will you consider inclusion of those tests into
the LTP or equivalent?

[Strange words like "leverage" and "synergy" are popping
  into my head but I'm suppressing them ;)]

thanks,
Nivedita


