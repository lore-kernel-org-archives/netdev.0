From: "James Kosin" <JKosin@intcomgrp.com>
Subject: RE: [PATCH 1/2] net: at91_ether.c - Allow transmitter interrupt to be handled first in ISR
Date: Thu, 14 Jan 2010 15:28:38 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD367402897539@MAILSRV.intcomgrp.com>
References: <3DBBD805E3BA064A87F551C0E8BD36740289748A@MAILSRV.intcomgrp.com> <20100113.173253.223656114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757635Ab0ANU0y@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100113.173253.223656114.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks David,

I'm checking out the latest git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
With git now...

A few items:
	a)  Is it OK to use git-diff to build a patch file?  Or does everyone still prefer
	    diff?

	b)  I'm going to try and test also; since, I do have an active platform I
	    can test on.  Are there any other developers using the ARM that may be able
	    to provide some feedback?  Eric Dumazet had some interesting comments
	    but, none of the original people in the file are around anymore I'm afraid.
	    That or they really don't want to be contacted.

Thanks Again,

James Kosin
