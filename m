From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: Kernel connector - userspace <-> kernelspace "linker".
Date: Tue, 21 Sep 2004 08:54:54 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0409210850460.3314@chaos.analogic.com>
References: <1095331899.18219.58.camel@uganda> <20040921124623.GA6942@uganda.factory.vocord.ru>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20040921124623.GA6942@uganda.factory.vocord.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,
This looks like a thinly veiled attempt to provide kernel
hooks so that non-GPL user-mode code can execute within
the kernel and trash it. I think the kernel developers
are smart enough so they won't allow any priviliged
kernel-mode 'callback' to user code.

Cheers,
Dick Johnson
Penguin : Linux version 2.4.26 on an i686 machine (5570.56 BogoMips).
            Note 96.31% of all statistics are fiction.
