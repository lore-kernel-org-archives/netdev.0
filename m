From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Extend netlink error codes
Date: Sun, 12 Sep 2004 16:37:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912163744.52f95367.davem@davemloft.net>
References: <20040910225158.GO20088@postel.suug.ch>
	<20040911155839.GN4431@wotan.suse.de>
	<20040911162433.GC21181@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040911162433.GC21181@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Sep 2004 18:24:33 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> > I don't think an very specific error like
> > "CFQ subsystem parameter X is FOO, can be only upto BAR" 
> > can be nicely put into a global error file.
> 
> True, I would really like to have such error messages.

I'd love to have them too.

But I know internationalization folks are going to
scream, although it will obviously be better than
no messages at all.
