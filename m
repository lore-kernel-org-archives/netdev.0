From: Jeff Garzik <jgarzik@pobox.com>
Subject: Another holiday tg3 release
Date: Mon, 30 Dec 2002 12:52:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021230175237.GA2547@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Another holiday, another set of tg3 releases.

first, there is an official, production update of tg3, version 1.2a:
http://people.redhat.com/jgarzik/tg3/tg3-1.2a/		(source code)
http://people.redhat.com/jgarzik/tg3/tg3-1.2a/rpms/	(red hat rpms)

second, for people still having problems, there are three experimental
sets of rpms, to be tried in this order:
http://people.redhat.com/jgarzik/tg3/tg3-1.2a/exp1-rpms/
http://people.redhat.com/jgarzik/tg3/tg3-1.2a/exp2-rpms/
http://people.redhat.com/jgarzik/tg3/tg3-1.2a/exp3-rpms/

experiment #1 - better irq mask/unmask for better speed and stability
		(test this!)
experiment #2 - ultra-safe version of #1, with less experimental stuff
experiment #3 - the riskiest of the bunch, but potentially faster

I would prefer that everyone who can try experiment #1, and back down to
experiment #2 if that doesn't work.

There is more information on the files in this directory in
http://people.redhat.com/jgarzik/tg3/tg3-1.2a/version-notes.txt

Disclaimer:  These are unofficial rpms created by myself.  They are not
officially released by Red Hat, so do not use them in production, etc.
