From: Sean Neakums <sneakums@zork.net>
Subject: Re: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Sun, 20 Jul 2003 20:47:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6usmp16kvu.fsf@zork.zork.net>
References: <Mutt.LNX.4.44.0307210116070.24197-100000@excalibur.intercode.com.au>
	<6uwued6lzv.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <6uwued6lzv.fsf@zork.zork.net> (Sean Neakums's message of "Sun,
 20 Jul 2003 20:23:16 +0100")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sean Neakums <sneakums@zork.net> writes:

> I ended up with about forty megabytes of tcpdump output on each side
> of the link before the hang occurred.  I've appended below the last
> 150 lines of each dump.  Four separate TCP connections were involved
> in all, for a total of about 400MiB of data transferred.

That is to say: the tree of files I was rsyncing is about 125MiB, and
I deleted the destination tree and repeated the transfer until I
reproduced the hang.
