From: Dorn Hetzel <kernel@dorn.hetzel.org>
Subject: Re: r8169.c
Date: Thu, 25 Nov 2004 17:02:33 -0500
Message-ID: <20041125220233.GA23850@lilah.hetzel.org>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041123144901.GA19005@lilah.hetzel.org> <20041123194740.GA32210@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dorn Hetzel <kernel@dorn.hetzel.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041123194740.GA32210@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 23, 2004 at 08:47:40PM +0100, Francois Romieu wrote:
> Dorn Hetzel <kernel@dorn.hetzel.org> :

> > Stacked on these 4 patches and things seem much better :)
> 
> Did you change the compiler as well ?
> 
> If yes, it would be nice to know if the system performs correctly when built with
> the previous compiler (feel free to answer #1 only if you are busy :o) ).
>

I went ahead and remotely rebuilt using gcc 2.95.4 and upon reboot it
worked long enough to ssh in and then it failed.  So it sounds like the
version of gcc DOES make a difference :)

I will report further details when I get home and can access the box
again ;)

-Dorn
 
> --
> Ueimor
> -
