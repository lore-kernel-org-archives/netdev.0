From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Thu, 23 Sep 2010 08:44:51 +0200
Message-ID: <1285224291.2380.112.camel@edumazet-laptop>
References: <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
	 <1285176935.2639.453.camel@edumazet-laptop>
	 <1285184088.2380.18.camel@edumazet-laptop> <4C9A7F7F.5010507@gmail.com>
	 <1285195419.2380.39.camel@edumazet-laptop>
	 <201009231532.JFD65132.OFtFSVFJHQOMLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, davem@davemloft.net,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <201009231532.JFD65132.OFtFSVFJHQOMLO@I-love.SAKURA.ne.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 23 septembre 2010 =C3=A0 15:32 +0900, Tetsuo Handa a =C3=A9cri=
t :
> Eric Dumazet wrote:
> > [PATCH v2] net: fix a lockdep splat
>=20
> The lockdep warning disappeared for both
> linux-2.6.35.5.tar.bz2 and linux-2.6.36-rc5.tar.bz2 .
>=20

Thanks Tetsuo !


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
