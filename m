From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 11:01:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929090103.GB18671@wotan.suse.de>
References: <20040928223344.GC2975@wotan.suse.de> <Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Does this help?

Possible. I don't have any plans to change the receiver because
it works well for most cases.

The problem must be still in the sender.

-Andi
