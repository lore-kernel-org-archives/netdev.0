From: "Dale E. Martin" <dale@the-martins.org>
Subject: Re: where is the proper place for r8169 bug reports?
Date: Mon, 31 Jan 2005 16:59:48 -0500
Message-ID: <20050131215948.GA23289@gerbil.toadis.porkis>
References: <20050131181508.GA15908@gerbil.toadis.porkis> <20050131214951.GA13217@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050131214951.GA13217@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> You can send info here and open a PR at bugzilla.kernel.org.

OK.  In general what I'm seeing is transmit timeout error that is locking
the machine up when I try to run at gigabit speed.  The board is a "Zonet"
brand card, hooked to a Netgear 8 port gigabit switch.

The same card worked in another machine so I'm guessing that the board
isn't a paper weight at least.
 
> If you are using a 2.95.x compiler (wild guess), it would be well advised
> to upgrade.

Hmmm, OK.  I'm running Debian stable so that is what cc defaults to.  I'll
recompile with 3.3 and see if the problems go away.  It could easily
explain the difference between machines too.

Thanks,
	Dale
-- 
Dale E. Martin - dale@the-martins.org
http://the-martins.org/~dmartin
