From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: [Bugme-new] [Bug 3784] New: Kernel Panic on huge portrange TCP scan (using nmap portscanner).
Date: Sun, 21 Nov 2004 00:52:13 +0100
Message-ID: <20041120235213.GZ31969@postel.suug.ch>
References: <20041120132749.5001bef1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: czkaw@poczta.fm
Content-Disposition: inline
In-Reply-To: <20041120132749.5001bef1.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Andrew Morton <20041120132749.5001bef1.akpm@osdl.org> 2004-11-20 13:27
>            Summary: Kernel Panic on huge portrange TCP scan (using nmap
>                     portscanner).
>     Kernel Version: Linux version 2.6.9 (slawek@ivision) (gcc version 3.3.4)

2.6.9 has a buggy TCP, can you please confirm against at least 2.6.10-rc2.
I was not able to repdroduce this in the described way.

Thanks.
