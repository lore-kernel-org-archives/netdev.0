From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [B.A.T.M.A.N.] [PATCH 2/2] net: Export IGMP/MLD
 message validation code
Date: Sat, 11 Apr 2015 03:46:45 +0200
Message-ID: <20150411014645.GA20155@odroid>
References: <1428687999-18428-1-git-send-email-linus.luessing@c0d3.blue>
	<1428687999-18428-2-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1428687999-18428-2-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 07:46:39PM +0200, Linus L=C3=BCssing wrote:
> diff --git a/net/ipv6/mcast_snoop.c b/net/ipv6/mcast_snoop.c
> new file mode 100644
> index 0000000..95b34c0
> --- /dev/null
> +++ b/net/ipv6/mcast_snoop.c
> @@ -0,0 +1,198 @@
> +/* Copyright (C) 2015: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

PS: I'm a little uncertain how this is usually done. If I should
add someone (maybe Hideaki YOSHIFUJI, the original author of the
bridge IPv6/MLD support?), then please let me know.
