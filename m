From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net] Bridge: Fix ipv6 mc snooping if bridge has
 no ipv6 address
Date: Tue, 28 Jun 2016 15:22:36 +0200
Message-ID: <20160628132236.GE3221@otheros>
References: <1466764518-11358-1-git-send-email-daniel@dd-wrt.com>
	<20160625142028.GF4407@otheros>
	<20160628.080442.1941457943482109633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, ulrich.weber@sophos.com, uw@ocedo.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160628.080442.1941457943482109633.davem@davemloft.net>
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

On Tue, Jun 28, 2016 at 08:04:42AM -0400, David Miller wrote:
> From: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
> [...]
> > Fixes: 1d81d4c3dd88 ("bridge: check return value of ipv6_dev_get_sadd=
r()")
>=20
> You're missing an initial 'd' in that SHA1-ID.
>=20
> With that fixed, applied and queued up for -stable.

Sorry :(. Thanks for taking care of it!
