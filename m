From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 22:20:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004202013.GE15898@postel.suug.ch>
References: <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net> <20041003233647.GN14344@postel.suug.ch> <1096852582.1046.378.camel@jzny.localdomain> <20041004125300.GA15898@postel.suug.ch> <1096896256.1072.4.camel@jzny.localdomain> <20041004141532.GB15898@postel.suug.ch> <1096901984.1073.9.camel@jzny.localdomain> <20041004193016.GD15898@postel.suug.ch> <1096920421.2156.13.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096920421.2156.13.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1096920421.2156.13.camel@jzny.localdomain> 2004-10-04 16:07
> Can you also change net/sched/estimator.c to behave the same way?

Sure, will do.

> BTW, anything else that changed since last time other than the timer
> adjustment ?

No, I removed the check, adjusted the timer calculation and updated
the notes in the documentation.
