From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Wed, 12 Sep 2007 22:50:25 +0200
Message-ID: <20070912205025.GA31709@electric-eye.fr.zoreil.com>
References: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com> <20070813165821.GA19356@electric-eye.fr.zoreil.com> <be1b757c0708131027v5c57822as2d9bd3190fd19b71@mail.gmail.com> <20070814070901.GA14693@electric-eye.fr.zoreil.com> <be1b757c0708141425qd887581n3922702b84a21758@mail.gmail.com> <20070814224629.GB3495@electric-eye.fr.zoreil.com> <20070816141122.GA6625@electric-eye.fr.zoreil.com> <be1b757c0709011224tafebaaby697d03ab5377e20f@mail.gmail.com> <6bffcb0e0709021515v586f078cjce04f877e2f27aa2@mail.gmail.com> <be1b757c0709021521q850f2bdq3f88c24c02c26b1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Karl Meyer <adhocrocker@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765520AbXILUxz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <be1b757c0709021521q850f2bdq3f88c24c02c26b1b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karl Meyer <adhocrocker@gmail.com> :
[...]
> am am looking for this issue for some time now, but there where no
> errors in 2.6.22-r2 (gentoo speak, I guess this is 2.6.22.2
> officially), I also ran git-bisect (for more information see the older
> messages in this thread).

2.6.22-r2 in gentoo is based on 2.6.22.1. It is way before
0e4851502f846b13b29b7f88f1250c980d57e944 that you reported to work.
Thus it is not surprizing that it works.

Any update regarding the patchkit that I sent on 2007/08/16 ?

It would help to narrow the culprit.

-- 
Ueimor
