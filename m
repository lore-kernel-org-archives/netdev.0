From: Rusty Russell <rusty@rustcorp.com.au>
Subject: "Loopback" route through two cards?
Date: Tue, 03 Sep 2002 15:04:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020903050441.4052F2C414@lists.samba.org>
Cc: kuznet@ms2.inr.ac.ru, anton@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

	I know this is an FAQ, but I never saw an answer I liked.  We
want to stress-test a couple of gigabit NICs by connecting them to
each other and routing packets out one and into the other.  Is this
still impossible without nat?

Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
