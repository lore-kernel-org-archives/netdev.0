From: Brad House <brad@mcve.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Sun, 23 Nov 2003 19:02:43 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC14AA3.9050009@mcve.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <3FC14058.4010600@mcve.com> <20031124004023.A1140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031124004023.A1140@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Heh, know you still have stuff to do on this, but I just
compiled it up and tested it, and figured I'd let you know
what I saw ...
The kernel locked hard on running a   dhcpcd eth0
no panic output to the screen (I don't have a serial cable
hooked up, or anything, so I don't know if it output anything
there)

I'm sure the 'pile' of code left from realtek left will fix it
though ;)

-Brad

Francois Romieu wrote:
> Brad House <brad@mcve.com> :
> 
>>cool. Did those previous patches you posted get merged into the
>>current netdrvr-exp1, or do those need to be applied as well ?
> 
> 
> It is built on top of 2.6.0-test9-bk27 + (latest) netdrvr-exp:
> ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-test9-bk25-netdrvr-exp1.patch.bz2
> 
> 
>>I'm going to see if I can test this out tonight...
> 
> 
> There is still a pile of code from realtek to merge. Tomorrow.
> 
> --
> Ueimor
> 
