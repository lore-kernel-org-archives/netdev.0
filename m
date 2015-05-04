From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv3 net-next 1/2] bridge: multicast: call
 skb_checksum_{simple_, }validate
Date: Mon, 4 May 2015 09:10:31 -0700
Message-ID: <20150504091031.1ff55398@urahara>
References: <1430568067-6912-1-git-send-email-linus.luessing@c0d3.blue>
	<1430568067-6912-2-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>
To: Linus =?UTF-8?B?TMO8c3Npbmc=?= <linus.luessing@c0d3.blue>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430568067-6912-2-git-send-email-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat,  2 May 2015 14:01:06 +0200
Linus L=C3=BCssing <linus.luessing@c0d3.blue> wrote:

> Let's use these new, neat helpers.
>=20
> Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
