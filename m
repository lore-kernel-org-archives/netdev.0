From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 00/14] Add common OF device tree support for MDIO busses
Date: Tue, 31 Mar 2009 19:45:02 -0600
Message-ID: <fa686aa40903311845v54ddfb91u56dd11eff64140d4@mail.gmail.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331.145738.36845509.davem@davemloft.net>
	<fa686aa40903311519m3108c697v52180d192975a3b1@mail.gmail.com>
	<20090331.152237.210090951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Joakim.Tjernlund@transmode.se, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, afleming@freescale.com, olof@lixom.net
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090331.152237.210090951.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2009 at 4:22 PM, David Miller <davem@davemloft.net> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Tue, 31 Mar 2009 16:19:42 -0600
>
>> On Tue, Mar 31, 2009 at 3:57 PM, David Miller <davem@davemloft.net> wrot=
e:
>> > It therefore didn't get any -next exposure, so it's unreasonable to
>> > merge this stuff now.
>>
>> Since when has sitting in a -next tree been a requirement for merging
>> when the series has been kept up to date and tested? =A0I purposefully
>> kept it out of -next to ensure that when it was applied for real to a
>> -next tree it would be as complete, bug free, and bisectable as
>> possible since once it hits a signed-off -next branch the individual
>> commit cannot be modified.
>
> I know your pissed off, but take a deep breath and consider this
> from my position.
>
> If I don't put a line in the sand somewhere, everyone can say
> "I've been working so hard, I posted it to the lists a thousand
> times, I have tons of testers" and I have to put the change in.
>
> That doesn't work, so please wait until the next release to get
> your changes in. =A0And get them into a tree that gets exposure
> in linux-next. =A0Then you have nothing to worry about.

Dammit.  Why did you have to go and sound so reasonable when I was all
geared up for a pointless flame war.

well... alright... but I reserve the right to be grumpy and surly for
a few days.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
