From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169.c
Date: Mon, 6 Dec 2004 00:37:56 +0100
Message-ID: <20041205233756.GB29236@electric-eye.fr.zoreil.com>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041205235519.GA21885@lilah.hetzel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dorn Hetzel <kernel@dorn.hetzel.org>
Content-Disposition: inline
In-Reply-To: <20041205235519.GA21885@lilah.hetzel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dorn Hetzel <kernel@dorn.hetzel.org> :
[...]
> I was wondering if the above 4 patches have made it into one of the
> rc? releases, or at least a rc?-mm?  ?

They need to apply on top of -netdev which is included in -mm.
I'll send the patch for inclusion in -mm so there is no need for
Jeff to hurry.

--
Ueimor
