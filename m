From: "=?ISO-8859-1?Q?Oliver_Pinter_(Pint=E9r_Oliv=E9r)?="
	<oliver.pntr@gmail.com>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 22:41:52 +0100
Message-ID: <6101e8c40801141341hcb17b08h2fd5244bccb21928@mail.gmail.com>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com>
	 <20080114125200.28cb4c69@deepthought>
	 <20080114210105.GG9847@does.not.exist>
	 <6101e8c40801141331n3cb66c04pc74ff07faf04c8fd@mail.gmail.com>
	 <20080114213453.GJ9847@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gregkh@suse.de
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:64806 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbYANVly convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 16:41:54 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2406437fga.17
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 13:41:52 -0800 (PST)
In-Reply-To: <20080114213453.GJ9847@does.not.exist>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/08, Adrian Bunk <bunk@kernel.org> wrote:
> On Mon, Jan 14, 2008 at 10:31:03PM +0100, Oliver Pinter (Pint=E9r Oli=
v=E9r)
> wrote:
> > I think, it is a potential security breakpoint, when applications w=
ith
> > root permission its read, then a machine is freezed, or only i thin
> > it's?
>
> When you are root there are infinite ways to kill your machine, so
> there's nothing security related about this issue.

Yes, i know, but when some application or daemons read some file with
running root privileges, then ...


thanks, then it is only a "feature" and not bug.
>
> > Thanks,
> > Oliver
>
> cu
> Adrian
>
> --
>
>        "Is there not promise of rain?" Ling Tan asked suddenly out
>         of the darkness. There had been need of rain for many days.
>        "Only a promise," Lao Er said.
>                                        Pearl S. Buck - Dragon Seed
>
>


--=20
Thanks,
Oliver
