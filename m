From: Andreas Schwab <schwab@suse.de>
Subject: Re: GigE on PowerMac G5
Date: Mon, 06 Mar 2006 11:40:59 +0100
Message-ID: <jefylvzwhw.fsf@sykes.suse.de>
References: <jebqwmfeh9.fsf@sykes.suse.de>
	<1141507000.17127.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1141507000.17127.4.camel@localhost.localdomain> (Benjamin
	Herrenschmidt's message of "Sun, 05 Mar 2006 08:16:40 +1100")
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Sat, 2006-03-04 at 15:53 +0100, Andreas Schwab wrote:
>> I suppose the NIC in the PowerMac G5 can do GigE, yet when plugged into a
>> GB switch it is only willing to talk 100MB with it.  Any idea why?  Kern=
el
>> is 2.6.16-rc5-git2.
>
> Works for me... Must be a problem with auto-neg and your switch, or the
> cable.... Can you check how the switch is configured maybe ? You can
> also try forcing the link speed with ethtool.

It's not the cable, I have swapped it with another system where Gb is
working fine.  Neither it's the switch port, I have swapped it too.  I
can't force the speed with ethtool either.  Any other idea what to look
for?

Andreas.

-- =

Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
