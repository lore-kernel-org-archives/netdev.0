From: Elmer <elmer@linking.ee>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Tue, 14 Oct 2003 10:39:52 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310141030260.308-100000@server>
References: <20031013231231.791317ff.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Noah J. Misch" <noah@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031013231231.791317ff.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



on the other hand,  consider following:

1. the card is shit, also, on ISA interface
2. most people do write configuration parameters into cards BIOS under DOS
and do not need interface for configuration.
3. all of contents should be in /proc/sys , as far as I remember, I have
tried to implement all via sysctl rather than procfs io.
4. there is a file, reading of which causes card reset. Most of people
need this.

Therefore sensible solution would be simple, whatever it is.

Elmer.
