From: Toke =?utf-8?Q?H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
Subject: Re: [PATCH 1/2] fq: support filtering a given tin
Date: Fri, 06 Oct 2017 12:30:15 +0200
Message-ID: <87zi94r2ko.fsf@toke.dk>
References: <20171006095333.26335-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?utf-8?Q?Micha=C5=82?= Kazior <kazikcz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171006095333.26335-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
> Add to the FQ API a way to filter a given tin, in order to
> remove frames that fulfil certain criteria according to a
> filter function.
>
> This will be used by mac80211 to remove frames belonging to
> an AP VLAN interface that's being removed.
>
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Acked-by: Toke H=C3=B8iland-J=C3=B8rgensen <toke-LJ9M9ZcSy1A@public.gmane.org>
