From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: sk_chk_filter() no longer mangles
 filter
Date: Sat, 12 Jul 2014 17:23:59 +0200
Message-ID: <53C1530F.7020603@redhat.com>
References: <53BF8DEC.4000307@kristov.de>  <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>  <53C10C8A.70706@redhat.com> <1405172956.3515.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Christoph Schulz <develop@kristov.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1405172956.3515.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/12/2014 03:49 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Add const attribute to filter argument to make clear it is no
> longer modified.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good point, thanks Eric.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
