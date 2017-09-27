From: Richard Weinberger <richard@sigma-star.at>
Subject: Re: WARNING: kernel stack frame pointer at ffff880156a5fea0 in bash:2103 has bad value 00007ffec7d87e50
Date: Wed, 27 Sep 2017 08:51:22 +0200
Message-ID: <41856500.WAzQIuoSLi@blindfold>
References: <2656822.vqnppgTvlm@blindfold> <1598510.AHGpDp18sh@blindfold> <20170926224246.mj6cxkkelc4sanda@treble>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, ast@kernel.org,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@kernel.org
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926224246.mj6cxkkelc4sanda@treble>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 27. September 2017, 00:42:46 CEST schrieb Josh Poimboeuf:
> > Here is another variant of the warning, it matches the attached .config:
> I can take a look at it.  Unfortunately, for these types of issues I
> often need the vmlinux file to be able to make sense of the unwinder
> dump.  So if you happen to have somewhere to copy the vmlinux to, that
> would be helpful.  Or if you give me your GCC version I can try to
> rebuild it locally.

There you go:
http://git.infradead.org/~rw/bpf_splat/vmlinux.xz

Thanks,
//richard

-- 
sigma star gmbh - Eduard-Bodem-Gasse 6 - 6020 Innsbruck - Austria
ATU66964118 - FN 374287y
