From: Antti Tuominen <ajtuomin@morphine.tml.hut.fi>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Fri, 18 Oct 2002 14:16:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018111625.GA19394@morphine.tml.hut.fi>
References: <20021017162624.GC16370@morphine.tml.hut.fi> <20021018.021802.87011078.yoshfuji@linux-ipv6.org> <m3wuohq78u.wl@karaba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, pekkas@netcore.fi,
   torvalds@transmeta.com, jagana@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA <mk@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <m3wuohq78u.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 18, 2002 at 02:56:33AM +0900, Mitsuru KANDA wrote:
> > [ipv6_tunnel]
> > 
> > I think this is almost ok.
> I think so.
> I know ipv6_tunnel is stable as I use.

Thanks for the vote of confidence :)

> plus:
>    (maybe not whole kernel issue)
> It is important to integrate your ipv6tunnel command into
> ifconfig(8) and/or ip(8).

Obviously we will provide patches to add that functionality to ip (and
maybe also ifconfig), if the code goes into the kernel.

Regards,

Antti

-- 
Antti J. Tuominen, Gyldenintie 8A 11, 00200 Helsinki, Finland.
Research assistant, Institute of Digital Communications at HUT
work: ajtuomin@tml.hut.fi; home: tuominen@iki.fi
