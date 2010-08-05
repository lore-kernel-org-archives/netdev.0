From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: GIT: net-*2.6 rebased...
Date: Thu, 5 Aug 2010 16:02:22 +0800
Message-ID: <AANLkTinf3+UE2L4uTr1buEfxuTa36vVjk4WspTN8edRs@mail.gmail.com>
References: <20100804.162141.15218463.davem@davemloft.net>
	<4C5A6EFE.7040703@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: Arnd Hannemann <arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C5A6EFE.7040703-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 5, 2010 at 3:57 PM, Arnd Hannemann <arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org> wrote:
> Hi,
>
> Am 05.08.2010 01:21, schrieb David Miller:
>>
>> Both net-2.6 and net-next-2.6 have been rebased.
>>
>> To be honest, if you've been pulling from my tree you can just keep
>> doing so if you want, it will look just as if I had merged Linus's
>> tree into net-2.6 et al.
>
> I there something broken with the trees on git.kernel.org?
>
> if I try to fetch from net-next-2.6, I get:
> fatal: The remote end hung up unexpectedly
>
> if I try to clone net-2.6:
> (e.g. git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>
> I get lots of errors reading the tags "does not point to a valid object!" and then:
> remote: error: Could not read 3cfc2c42c1cbc8e238bb9c0612c0df4565e3a8b4
> remote: fatal: Failed to traverse parents of commit 7aaaaa1e44b2a4047dfe05f304a5090eb995cf44
> remote: aborting due to possible repository corruption on the remote side.
> fatal: early EOF
> fatal: index-pack failed
>
> I'm using git version 1.7.1.
>

me 2 for net-next-2.6

localhost linux # git pull
fatal: The remote end hung up unexpectedly
localhost linux # git version
git version 1.7.1


-- 
Regards,
Changli Gao(xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
