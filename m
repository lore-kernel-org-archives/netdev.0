From: Andi Kleen <ak@suse.de>
Subject: Re: Fwd: in-driver QoS
Date: Tue, 8 Jun 2004 00:58:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607225825.GA30647@wotan.suse.de>
References: <200406072217.31924.vkondra@mail.ru> <40C4C42F.2040006@pobox.com> <200406072328.23836.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        James Ketrenos <jketreno@linux.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
Content-Disposition: inline
In-Reply-To: <200406072328.23836.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I know very little about ATM, but it have QoS, both diff serv and int serv. 
> May be it is worth to borrow from it?

ATM and IP diffserv just use the qdisc framework in the kernel.

-Andi
