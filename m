From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Thu, 23 Sep 2004 22:53:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923225321.7a19117d.davem@davemloft.net>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
	<20040921203118.734a0a7e.davem@davemloft.net>
	<20040922111447.GP3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040922111447.GP3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 13:14:47 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> And I still want to address the "all complete entries flushed due to
> lots of bogus incomplete entires" issue somehow.  As stated before, I
> have seen this on happen on live systems.  
> 
> Do you agree that this is an existing problem?

I totally agree.  Please scan my 6 patches, let's get that
all fleshed out, then we can move on to this issue.

Feel free to backport my 2.6.x neigh patches so far and
send that work to me, I'll happily integrate them into
my 2.4.x net tree.
