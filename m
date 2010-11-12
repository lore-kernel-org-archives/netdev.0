From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: a problem tcp_v4_err()
Date: Fri, 12 Nov 2010 21:31:08 +0300
Message-ID: <20101112183108.GB20459@ms2.inr.ac.ru>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com> <00c201cb81eb$84e18160$8ea48420$@com> <1289578108.3083.95.camel@localhost.localdomain> <1289578532.3185.265.camel@edumazet-laptop> <20101112163543.GB122902@jupiter.n2.diac24.net> <4CDD7145.8070606@trash.net> <20101112175715.GB16544@ms2.inr.ac.ru> <1289585578.3185.268.camel@edumazet-laptop> <1289586114.3185.271.camel@edumazet-laptop> <1289586477.3185.273.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Lamparter <equinox@diac24.net>,
	Eric Paris <eparis@redhat.com>, Hua Zhong <hzhong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, paul.moore@hp.com,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1289586477.3185.273.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Oh well, it seems you are right (backlog processing)

Exactly.

Alexey
