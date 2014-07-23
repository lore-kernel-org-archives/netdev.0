From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 0/6] net: mvpp2: Assorted fixes
Date: Wed, 23 Jul 2014 07:53:18 -0300
Message-ID: <20140723105318.GA1729@arch.cereza>
References: <20140723002916.67a0bb3c@free-electrons.com>
 <20140722232004.GA7838@arch.cereza>
 <20140722.174153.413669013449137654.davem@davemloft.net>
 <20140722.195222.775371949777233094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: thomas.petazzoni@free-electrons.com, alior@marvell.com,
 jason@lakedaemon.net, tawfik@marvell.com, netdev@vger.kernel.org,
 gregory.clement@free-electrons.com, mw@semihalf.com,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20140722.195222.775371949777233094.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 22 Jul 07:52 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 22 Jul 2014 17:41:53 -0700 (PDT)
> =

> > From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> > Date: Tue, 22 Jul 2014 20:20:04 -0300
> > =

> >> On 23 Jul 12:29 AM, Thomas Petazzoni wrote:
> >>> On Tue, 22 Jul 2014 13:16:39 -0700 (PDT), David Miller wrote:
> >>> =

> >>> > >> This series does not apply to the 'net' tree at all, please resp=
in
> >>> > >> and resubmit.
> >>> > > =

> >>> > > This series applies on net-next.
> >>> > > =

> >>> > > Sorry for not mentioning it,
> >>> > =

> >>> > They are bonafide bug fixes, therefore should be targetted at 'net'.
> >>> =

> >>> Except that I believe they are fixes for a driver which itself is in
> >>> net-next, i.e scheduled for 3.17.
> >>> =

> >> =

> >> That's right. These are fixes for the new mvpp2 driver, which is only
> >> in net-next.
> > =

> > Ok, I queued them back up, thanks for the clarification.
> =

> I've applied the 4 driver patches to net-next.  But, since the ARM
> device tree file changes did not go into net-next, I can't apply the
> last two patches to my tree.  You'll need to sort that out yourself.
> =

> It's a bit unfortunate that things are now out of sync like this, but
> that's what you asked me to do.

Thanks for applying this. We'll queue the devicetree changes as fixes
for v3.17-rc1 through the arm-soc tree.
-- =

Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
