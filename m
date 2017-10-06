From: Toke =?utf-8?Q?H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
Subject: Re: [PATCH 2/2] mac80211: only remove AP VLAN frames from TXQ
Date: Fri, 06 Oct 2017 12:30:24 +0200
Message-ID: <87wp48r2kf.fsf@toke.dk>
References: <20171006095333.26335-1-johannes@sipsolutions.net> <20171006095333.26335-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?utf-8?Q?Micha=C5=82?= Kazior <kazikcz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171006095333.26335-2-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
> When removing an AP VLAN interface, mac80211 currently purges
> the entire TXQ for the AP interface. Fix this by using the FQ
> API introduced in the previous patch to filter frames.
>
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Acked-by: Toke H=C3=B8iland-J=C3=B8rgensen <toke-LJ9M9ZcSy1A@public.gmane.org>
