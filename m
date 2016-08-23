From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: checkpatch: See if modified files are marked obsolete in
 MAINTAINERS
Date: Tue, 23 Aug 2016 06:18:11 -0400 (EDT)
Message-ID: <alpine.DEB.2.10.1608230617420.3523@hadrien>
References: <87shtwvm63.fsf@kamboji.qca.qualcomm.com> <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com> <d5365370-37b5-b367-ba9e-45f4e27f975a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Andy Whitcroft <apw@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d5365370-37b5-b367-ba9e-45f4e27f975a@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 23 Aug 2016, SF Markus Elfring wrote:

> > Use get_maintainer to check the status of individual files.
> > If "obsolete", suggest leaving the files alone.
>
> Will another software system like the "kbuild test robot"
> need any more fine-tuning for this change?

It only works on files in which there have been commits, thus by
definition not obsolete.

julia


>
> Regards,
> Markus
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
