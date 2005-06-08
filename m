From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netdev munching messages again?
Date: Wed, 8 Jun 2005 22:00:48 +0200
Message-ID: <20050608200048.GP20969@postel.suug.ch>
References: <20050607140842.778143000@axs> <20050607140901.632982000@axs> <20050607213621.GG20969@postel.suug.ch> <20050607.144237.93024273.davem@davemloft.net> <20050608132953.GK20969@postel.suug.ch> <1118238264.6382.43.camel@localhost.localdomain> <20050608160444.GA17777@linux-mips.org> <20050608161314.GM20969@postel.suug.ch> <20050608172809.GF5520@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20050608172809.GF5520@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ralf Baechle <20050608172809.GF5520@linux-mips.org> 2005-06-08 18:28
> Whatever it was, it was probably a separate issue from this spamfilter
> faux-pas.  Note there is a firewall in front of oss.sgi.com which will
> accept the SMTP TCP connection only to drop the connection shortly after
> if it can't build a connection to the "real" oss.

I'm not worried about a refused connections once in a while, I'm
worried about that exactly those two messages that have been 
sitting in _my_ queue due to a refused connection to oss.sgi.com
have been succesfully delivered and the others have not.

Is there a messages/time limit somwhere? If so what's the limit?
I tried with 30 seconds delay between each patch but that didn't
help.
