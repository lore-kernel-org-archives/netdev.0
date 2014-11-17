From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix netfilter/NF_BR_LOCAL_OUT for own,
 locally generated queries
Date: Mon, 17 Nov 2014 01:12:44 -0500 (EST)
Message-ID: <20141117.011244.411942491718443458.davem@davemloft.net>
References: <1411342364-4791-1-git-send-email-linus.luessing@web.de>
	<20141102220145.GA25604@gondor.apana.org.au>
	<20141117020816.GD2469@odroid>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20141117020816.GD2469@odroid>
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

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Mon, 17 Nov 2014 03:08:16 +0100

> On Mon, Nov 03, 2014 at 06:01:46AM +0800, Herbert Xu wrote:
>> On Mon, Sep 22, 2014 at 01:32:44AM +0200, Linus L=FCssing wrote:
>> > Signed-off-by: Linus L=FCssing <linus.luessing@web.de>
>> =

>> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> =

> Hi David,
> =

> are there any unanswered questions left?

I expect to get this from the netfilter folks, since it is a
netfilter change.  So you should submit it to the netfilter
maintainers.
