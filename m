From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 and tg3
Date: Tue, 18 Nov 2003 13:58:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118135848.A2451@electric-eye.fr.zoreil.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brad House <brad_mssw@gentoo.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FB9A277.70309@pobox.com>; from jgarzik@pobox.com on Mon, Nov 17, 2003 at 11:39:19PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> So, what needs to happen is somebody needs to look at the sis190 changes 
> that went in, and apply those same fixes to r8169.

If no one objects, I can do for r8169 the same thing I did for sis190.
Btw the DMA Rx/Tx rework is already in good shape (I rather like seeing
Jeff improving (S)ATA than coming to copy over his RX and TX handling
code :o) ).

Anyway, the bk-commit patches which were related to sis190 are available at:
http://www.fr.zoreil.com/people/francois/misc/sis190-rework.mbx

--
Ueimor
