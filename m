From: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: batman-adv: use new api
	ethtool_{get|set}_link_ksettings
Date: Fri, 31 Mar 2017 22:33:34 +0200
Message-ID: <CAC=8w91DZHq4dKzUS=8w1fUvPG_CmT=HT3amQ15-iVgAV23fmQ@mail.gmail.com>
References: <1490907687-11784-1-git-send-email-tremyfr@gmail.com>
 <5459529.jjAg0OrKDG@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, a@unstable.cc, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5459529.jjAg0OrKDG@bentobox>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi Sven,

On 3/31/17, Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org> wrote:
> On Donnerstag, 30. M=C3=A4rz 2017 23:01:27 CEST Philippe Reynes wrote:
>> The ethtool api {get|set}_settings is deprecated.
>> We move this driver to new api {get|set}_link_ksettings.
>>
>> I've only compiled this change. If someone may test it,
>> it would be very nice.
>>
>> Signed-off-by: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  net/batman-adv/soft-interface.c |   25 ++++++++++++-------------
>>  1 files changed, 12 insertions(+), 13 deletions(-)
>
> Do you know if anyone already prepared the get_link_ksettings support for
> kernels older than 4.6 for backports.git?

Sorry, I don't know this repo. Do you have an url please ?
But I suppose that nobody works on such backport.

> Kind regards,
> 	Sven

Regards,
Philippe
