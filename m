From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: promote netfilter MARK value from IPv6 packets to sit
 packets
Date: Mon, 24 Feb 2003 08:41:10 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030224083946.H34066@shell.cyberus.ca>
References: <20030217145727.GA3413@hensema.net> <20030223193339.GD15385@sunbeam.de.gnumonks.org>
 <20030223234225.GA23556@hensema.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Harald Welte <laforge@netfilter.org>, "" <netdev@oss.sgi.com>,
   Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Erik Hensema <erik@hensema.net>
In-Reply-To: <20030223234225.GA23556@hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



If this is to be a config option, it should not be restricted to
netfilter specifics but rather skb specifics. Example the tcindex
(maybe even the cb) etc.

cheers,
jamal
