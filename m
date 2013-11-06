From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: don't forget to free sk_filter
Date: Wed, 6 Nov 2013 11:44:23 -0800
Message-ID: <CAMEtUuz51grUwaz+qzpmGLENx5WFJoMs0WuU2UMN8cmUoPpShg@mail.gmail.com>
References: <1383753106-26978-1-git-send-email-avagin@openvz.org>
	<527A9638.4020404@redhat.com>
	<1383766098.21999.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Andrey Vagin <avagin@openvz.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383766098.21999.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 6, 2013 at 11:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Actually, the new way [1] of doing this would be to use the 'Fixes:' tag
> as in :
>
> Fixes: <12 digits SHA1> ("net: fix unsafe set_memory_rw from softirq")
>
> [1] As discussed at last Kernel Summit

thx. good to know.
Unfortunately 2013 Kernel Summit proceedings are not public (yet?),
but available to paid LWN subscribers.
