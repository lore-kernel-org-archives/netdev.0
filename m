From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 21:28:40 -0200
Message-ID: <39e6f6c70511021528u513a9b4fn44497ddb2f672a28@mail.gmail.com>
References: <OF395F8772.5B834BF9-ON882570AC.0075ACD7-882570AC.0075DC3C@us.ibm.com>
	 <4367FF22.3030601@21cn.com>
	 <39e6f6c70511021355i52aff7e4n19ca4c1e24b21bb7@mail.gmail.com>
	 <43694B94.7010605@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030194AbVKBX2m@vger.kernel.org>
To: Yan Zheng <yanzheng@21cn.com>
In-Reply-To: <43694B94.7010605@21cn.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/2/05, Yan Zheng <yanzheng@21cn.com> wrote:
> >
> > Could you please compile test it next time :-) hint, missing ';'.
> > Anyway, fixed up by hand.
> >
> > - Arnaldo
> >
> >
>
> I'm so sorry.

Don't worry, I already fixed it and published in my net-2.6.git tree at
www.kernel.org, its just that the same confidence that makes one
commit something simple as in your case could introduce something
nasty :-)

- Arnaldo
