From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: link state detection for 8139too against 2.5.41
Date: Sun, 13 Oct 2002 14:49:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA96BCC.B2589AC0@isg.de>
References: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@mandrakesoft.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> > I've written this stuff on a friends' computer using 2.4.18, so it is
> > only slightly tested.
> 
> Uhmmm, you don't need to poll with the rtl8139.  There is a link change
> interrupt.  Here is the recently added from rtl8139.c

ok, I'll try this next time I have access to the card.

Stefan
