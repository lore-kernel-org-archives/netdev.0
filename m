From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netdev munching messages again?
Date: Wed, 08 Jun 2005 13:10:44 -0700 (PDT)
Message-ID: <20050608.131044.31642070.davem@davemloft.net>
References: <20050608161314.GM20969@postel.suug.ch>
	<20050608172809.GF5520@linux-mips.org>
	<20050608200048.GP20969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050608200048.GP20969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 8 Jun 2005 22:00:48 +0200

> I'm not worried about a refused connections once in a while, I'm
> worried about that exactly those two messages that have been 
> sitting in _my_ queue due to a refused connection to oss.sgi.com
> have been succesfully delivered and the others have not.
> 
> Is there a messages/time limit somwhere? If so what's the limit?
> I tried with 30 seconds delay between each patch but that didn't
> help.

I see the delay due to SGI's firewall when I send postings
out too, and it's very annoying.

The fact that I can send an email faster to Herbert Xu
in Australia (several thousand miles away) than oss.sgi.com
(which is a short drive away) would be an amusing anecdote
if it didn't negatively impact my work.

I think it's time to move this list to a more reliable and
efficient place.

Ralf, thanks for all of your effort and time maintaining
oss.sgi.com for our stay as guests via the netdev list.

I've created netdev@vger.kernel.org, and folks can start
to join up there.  If someone knows the appropriate
archive maintainers to contact (marc.theaimsgroup.com
et al.) please let them know about this transition.  It
would be much apprecited.
