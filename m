From: kuznet@ms2.inr.ac.ru
Subject: Re: [RFC] Options for ECN target
Date: Tue, 6 Aug 2002 17:47:56 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208061347.RAA24323@sex.inr.ac.ru>
References: <20020806083541.L11828@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: laforge@gnumonks.ORG (Harald Welte)
In-Reply-To: <20020806083541.L11828@sunbeam.de.gnumonks.org> from "Harald Welte" at Aug 6, 2 12:15:09 pm
List-Id: netdev.vger.kernel.org

Hello!

> The first option is necessarry and is the primary use of the target.
> The last three options are more experimental and would allow somebody
> to play with 'simulated congestion' by setting the ECT in IP, etc.
...
> However, this is potentially very dangerous

Yes, they are illegal.

I would not say "very dangerous". Surely, much less dangerous
than cp /dev/zero /dev/mem. :-)

So, I think it can be added for debugging purposes, provided hidden
in a section devoted to debugging in manual and not shown in command
line helper.

Alexey
