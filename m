From: Dorn Hetzel <kernel@dorn.hetzel.org>
Subject: Re: r8169.c
Date: Thu, 25 Nov 2004 15:00:22 -0500
Message-ID: <20041125200022.GA12674@lilah.hetzel.org>
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
> [...]
> > Stacked on these 4 patches and things seem much better :)
> 
> Did you change the compiler as well ?
> 
> If yes, it would be nice to know if the system performs correctly when built with
> the previous compiler (feel free to answer #1 only if you are busy :o) ).
>

Yes, I moved to gcc 3.4.3.

I'm out of town for the Thanksgiving holiday, but I will revert the compiler
and test again as soon as I get home (early next week).

Do you know when the 250-265 patches will be merged and into which train?

Best Regards,

-Dorn
 
> --
> Ueimor
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
