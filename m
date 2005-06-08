From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: netdev munching messages again?
Date: Wed, 8 Jun 2005 17:04:45 +0100
Message-ID: <20050608160444.GA17777@linux-mips.org>
References: <20050607140842.778143000@axs> <20050607140901.632982000@axs> <20050607213621.GG20969@postel.suug.ch> <20050607.144237.93024273.davem@davemloft.net> <20050608132953.GK20969@postel.suug.ch> <1118238264.6382.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1118238264.6382.43.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 09:44:23AM -0400, jamal wrote:

> I thought netdev just picks on me ;-> My stoopid ISP as well
> as oss.sgi.com have some "clever" (read: questionable) ways 
> of delivering email which violates end to end semantics of SMTP.
> I too noticed some emails were swallowed in the last 1-2 days. I know
> from past experience in fact they will never be seen again;->
> Or someone, who doesnt look at the headers, will flame me for repeating
> what has already been discussed and agreed on (has happened to me at
> least 5 times on netdev ;->).
> 
> It's quiet ironic when packets delivered over TCP dont make it to the
> remote end, even when the app tries to help in reliable delivery;->
> 
> CCing El-sido Bacchus.

Turns out that Thomas Graf's Email was intercepted by the spam filter,
so I've tweaked the filter setup a bit - probably at the price of
sacrificing some of the filter's effectivity.

It unfortunately has become totally impractical to walk through the
hundreds of moderator emails every day due to the volume, so I need to
rely on people to report about such problem to postmaster@oss.sgi.com
or me directly via email or irc.

As for resending messages, due to people doing stupid things such as
restoring their mail and news spools oss is keeping a non-expiring list
of message IDs.  However only non-spam message IDs are being recorded.

  Ralf
