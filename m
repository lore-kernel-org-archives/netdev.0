From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NAPI, e100, and system performance problem
Date: Tue, 19 Apr 2005 11:36:57 -0700
Message-ID: <20050419113657.7290d26e.davem@davemloft.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, akepner@sgi.com, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20050419055535.GA12211@sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2005 15:55:35 +1000
Greg Banks <gnb@sgi.com> wrote:

> > How do you recognize when system resources are being poorly utilized?
> 
> An inordinate amount of CPU is being spent running around polling the
> device instead of dealing with the packets in IP, TCP and NFS land.
> By inordinate, we mean twice as much or more cpu% than a MIPS/Irix
> box with slower CPUs.

You haven't answered the "how" yet.

What tools did you run, what did those tools attempt to measure, and
what results did those tools output for you so that you could determine
your conclusions with such certainty?
