From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 9/11] PKT_SCHED: Cleanup cls_set_class
Date: Wed, 27 Oct 2004 14:38:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027143819.3c92655a.davem@davemloft.net>
References: <20041026222148.GA12289@postel.suug.ch>
	<20041026222813.GJ12289@postel.suug.ch>
	<1098867450.1813.37.camel@cyan.cph.tpack.net>
	<20041027094238.GM12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041027094238.GM12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 11:42:38 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> > This locks once too many.
> > (And it returns an *unsigned* long.)
> 
> Thanks. I wonder how this lock could get in there.
> 
> 
> Remove bogus lock and make cls_set_class return unsigned long.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
