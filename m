From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: 30 Dec 2004 23:45:36 -0500
Message-ID: <1104468336.1048.205.camel@jzny.localdomain>
References: <41D3785F.3040909@trash.net>
	 <1104382562.1048.39.camel@jzny.localdomain> <41D3F5EC.9050808@trash.net>
	 <41D4286B.1060106@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D4286B.1060106@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 11:10, Patrick McHardy wrote:

> Thinking about it, I think its better to reorganize the
> patches by subject. While doing this I'm going to add
> back the useful printks in the init paths as DPRINTKs.
> I'm going to post the entire reorganized batch next week
> when I return home, working with bitkeeper on my crappy
> notebook is just to painful :)

[I dont use bitkeeper for religious reasons (i hope i am not
offending anyone)].
Ok, sounds like a good plan (gives me more time to work with the driver
stuff which is getting out of control ;->): I think the patches may have
goten a little messy. Maybe the order should be: you, Thomas with what
he has now then myself with eaction and Thomas with extended matches (I
dont think the order of the last two matters). I will just code against
whatever latest release is and migrate later when all the otehr patches
are in.

cheers,
jamal
