From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Linux 2.4.27 SECURITY BUG - TCP Local and REMOTE(verified)
	Denial of Service Attack
Date: Sun, 12 Sep 2004 18:17:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095009440.11736.14.camel@localhost.localdomain>
References: <029201c498d8$dff156f0$0300a8c0@s>
	 <001c01c498df$8d2cd0f0$0200a8c0@wolf>
	 <20040912175946.GA3491@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wolfpaw - Dale Corse <admin@wolfpaw.net>, peter@mysql.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20040912175946.GA3491@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sul, 2004-09-12 at 18:59, Willy Tarreau wrote:
> The problem is within inetd. In my case it could be because it was a bit
> old (1999), but since you have it too,

Ancient inetd had several fd leak bugs fixed over time and some other
problems with built in services. Not much of a suprise that a 1999 inetd
has it.

Alan
