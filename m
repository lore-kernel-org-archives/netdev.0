From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Wed, 25 Jun 2003 23:03:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306252303.13366.folkert@vanheusden.com>
References: <200306252248.44224.nf@hipac.org>
Reply-To: folkert@vanheusden.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <200306252248.44224.nf@hipac.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> nf-hipac is a drop-in replacement for the iptables packet filtering module.
> It implements a novel framework for packet classification which uses an
> advanced algorithm to reduce the number of memory lookups per packet.
> The module is ideal for environments where large rulesets and/or high
> bandwidth networks are involved. Its userspace tool, which is also called
> 'nf-hipac', is designed to be as compatible as possible to 'iptables -t
> filter'.

Looks great!
Any chance on a port to 2.5.x?


Greetings,

Folkert van Heusden

+-> www.vanheusden.com       folkert@vanheusden.com       +31-6-41278122 <-+
+--------------------------------------------------------------------------+
| UNIX sysop? Then give MultiTail ( http://www.vanheusden.com/multitail/ ) |
| a try, it brings monitoring logfiles (and such) to a different level!    |
+--------------------------------------------------------------------------+
