From: "David S. Miller" <davem@davemloft.net>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 14:46:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915144624.1339fbc5.davem@davemloft.net>
References: <4148991B.9050200@pobox.com>
	<Pine.NEB.4.33.0409151704200.5383-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, leonid.grossman@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409151704200.5383-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 17:36:18 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> The other (much nicer) solution to case (b) is to just USE A BIGGER MTU.
> 1500 bytes is ridiculously small.  Even with a 9k MTU, the benefits of TOE
> or TSO are nearly vanishing.  Those who say they require high performance,
> but are unwilling to buy or produce networking gear with an MTU larger
> than 1500 bytes probably deserve what they get.

TSO gives a kind of virtual 64K MTU, FWIW.  But I do see your
point.
