From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 4 Oct 2004 13:07:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004130756.057c1729.davem@davemloft.net>
References: <Pine.NEB.4.33.0409301625560.13549-100000@dexter.psc.edu>
	<Pine.NEB.4.33.0410011934160.26321-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0410011934160.26321-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Oct 2004 21:32:25 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> The good machine has an e7500 chipset and a 82544EI. The bad machine has a
> ServerWorks chipset and a 82545GM.
> 
> Any suggestions on where to look for what's going wrong with the
> interface?

Time to consult the e1000 driver maintainers probably.
There are threee folks mentioned in linux/MAINTAINERS
as contacts.
