From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 16:55:28 +0200
Message-ID: <48317843-b488-8ccb-c6c5-e8cbb90ff5e3@pengutronix.de>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>
 <da663b5a-5459-2e99-79a2-3fdc3daef70b@pengutronix.de>
 <74482aa8-7b65-bd3d-7160-0d515b8c7b27@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="TtKQ68UJ95PBw2X3uXia4AliN1N03Aujw"
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: Franklin S Cooper Jr <fcooper@ti.com>,
        Sekhar Nori <nsekhar@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
        socketcan@hartkopp.net, quentin.schulz@free-electrons.com,
        edumazet@google.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <74482aa8-7b65-bd3d-7160-0d515b8c7b27@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TtKQ68UJ95PBw2X3uXia4AliN1N03Aujw
Content-Type: multipart/mixed; boundary="jhs9HhASVTqFxb8JAgocweFLR1m7qbUth";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Franklin S Cooper Jr <fcooper@ti.com>, Sekhar Nori <nsekhar@ti.com>,
 =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
 "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
 socketcan@hartkopp.net, quentin.schulz@free-electrons.com,
 edumazet@google.com, linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Wenyou Yang <wenyou.yang@atmel.com>, Dong Aisheng <b29396@freescale.com>,
 "Quadros, Roger" <rogerq@ti.com>
Message-ID: <48317843-b488-8ccb-c6c5-e8cbb90ff5e3@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>
 <da663b5a-5459-2e99-79a2-3fdc3daef70b@pengutronix.de>
 <74482aa8-7b65-bd3d-7160-0d515b8c7b27@ti.com>
In-Reply-To: <74482aa8-7b65-bd3d-7160-0d515b8c7b27@ti.com>

--jhs9HhASVTqFxb8JAgocweFLR1m7qbUth
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable

On 10/19/2017 03:54 PM, Franklin S Cooper Jr wrote:
> On 10/19/2017 06:32 AM, Marc Kleine-Budde wrote:
>> On 10/19/2017 01:09 PM, Sekhar Nori wrote:
>>> On Thursday 19 October 2017 02:43 PM, Marc Kleine-Budde wrote:
>>>> On 10/19/2017 07:07 AM, Sekhar Nori wrote:
>>>>>>>> Sounds reasonable. What's the status of this series?
>>>>>>>
>>>>>>> I have had some offline discussions with Franklin on this, and I =
am not
>>>>>>> fully convinced that DT is the way to go here (although I don't h=
ave the
>>>>>>> agreement with Franklin there).
>>>>>>
>>>>>> Probably the fundamental area where we disagree is what "default" =
SSP
>>>>>> value should be used. Based on a short (< 1 ft) point to point tes=
t
>>>>>> using a SSP of 50% worked fine. However, I'm not convinced that th=
is
>>>>>> default value of 50% will work in a more "traditional" CAN bus at =
higher
>>>>>> speeds. Nor am I convinced that a SSP of 50% will work on every MC=
AN
>>>>>> board in even the simplest test cases.
>>>>>>
>>>>>> I believe that this default SSP should be a DT property that allow=
s any
>>>>>> board to determine what default value works best in general.
>>>>>
>>>>> With that, I think, we are taking DT from describing board/hardware=

>>>>> characteristics to providing default values that software should us=
e.
>>>>
>>>> If the default value is board specific and cannot be calculated in
>>>> general or from other values present in the DT, then it's from my po=
int
>>>> of view describing the hardware.
>>>>
>>>>> In any case, if Marc and/or Wolfgang are okay with it, binding
>>>>> documentation for such a property should be sent to DT maintainers =
for
>>>>> review.
>>>>>
>>>>>>>
>>>>>>> There are two components in configuring the secondary sample poin=
t. It
>>>>>>> is the transceiver loopback delay and an offset (example half of =
the bit
>>>>>>> time in data phase).
>>>>>>>
>>>>>>> While the transceiver loopback delay is pretty board dependent (a=
nd thus
>>>>>>> amenable to DT encoding), I am not quite sure the offset can be
>>>>>>> configured in DT because its not really board dependent.
>>>>>>>
>>>>>>> Unfortunately, offset calculation does not seem to be an exact sc=
ience.
>>>>>>> There are recommendations ranging from using 50% of bit time to m=
aking
>>>>>>> it same as the sample point configured. This means users who need=
 to
>>>>>>> change the SSP due to offset variations need to change  their DT =
even
>>>>>>> without anything changing on their board.
>>>>>>>
>>>>>>> Since we have a netlink socket interface to configure sample poin=
t, I
>>>>>>> wonder if that should be extended to configure SSP too (or at lea=
st the
>>>>>>> offset part of SSP)?
>>>>>>
>>>>>> Sekhar is right that ideally the user should be able to set the SS=
P at
>>>>>> runtime. However, my issue is that based on my experience CAN user=
s
>>>>>> expect the driver to just work the majority of times. For unique u=
se
>>>>>> cases where the driver calculated values don't work then the user =
should
>>>>>> be able to override it. This should only be done for a very small
>>>>>> percentage of CAN users. Unless you allow DT to provide a default =
SSP
>>>>>> many users of MCAN may find that the default SSP doesn't work and =
must
>>>>>> always use runtime overrides to get anything to work. I don't thin=
k that
>>>>>> is a good user experience which is why I don't like the idea.
>>>>>
>>>>> Fair enough. But not quite sure if CAN users expect CAN-FD to "just=

>>>>> work" without doing any bittiming related setup.
>>>>
>>>> From my point of view I'd rather buy a board from a HW vendor where
>>>> CAN-FD works, rather than a board where I have to tweak the bit-timi=
ng
>>>> for a simple CAN-FD test setup.
>>>>
>>>> As far as I see for the m_can driver it's a single tuple: "bitrate >=
 2.5
>>>> MBit/s -> 50%". Do we need an array of tuples in general?
>=20
> Internally what I proposed was a binding that allowed you to pass in an=

> array of a range of baud rates and then a SSP for that baud rate range.=

> Therefore, if the baud rate being used impacted what SSP worked then it=

> allows someone to provide a range of defaults. Of course a person also
> has the ability to use a single large range thus implementing a single
> default SSP value.

A single tuple is just a special case of a list of tuples :)

I was thinking of something like this:

First we need a struct defining the bitrate spp relationship.

The driver provides default values by a sorted array of these structs
together with array length.

During device registration we assign these default values to the actual
driver instance.

The netlink code can read and overwrite the current values. Maybe it can
read the default values.

The bitrate calculation code calculates the to be used spp value.

The driver sets the value during the open callback.

>> Do we need more than one tuple here?
>>
>>>> If good default values are transceiver and board specific, they can =
go
>>>> into the DT. We need a generic (this means driver agnostic) binding =
for
>>>> this. If this table needs to be tweaked for special purpose, then we=
 can
>>>> add a netlink interface for this as well.
>>>>
>>>> Comments?
>>>
>>> I dont know how a good default (other than 50% as the starting point)=

>>> can be arrived at without doing any actual measurements on the actual=

>>> network. Since we do know that the value has to be tweaked, agree tha=
t
>>> netlink interface has to be provided.
>=20
> Now I have seen in non public documentations that setting SP to SSP als=
o
> works.

This can already by done now, without the need for new interfaces.

> This makes a bit more sense to me and I'm alot more comfortable going
> with this. However, since its based on non public information I can't
> justify it beyond that "it works for me". But I'm alot more=20
> comfortable going with then saying "hey this default value works for=20
> TI's dra76 evm. Therefore, every MCAN board will be stuck by default
> for a value that works for us". So if there is no push back with
> going with SSP =3D db SP with no documentation to back up why that is
> being used then I will try that out and send patches.

This means we postpone the whole add-new-interface-dance until the
SPP=3DSP approach doesn't work for some usecase?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--jhs9HhASVTqFxb8JAgocweFLR1m7qbUth--

--TtKQ68UJ95PBw2X3uXia4AliN1N03Aujw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnovOAACgkQHv7KIOw4
HPZdoQgAz5CqIwXwfgL9azrex88eEBb2em/XguSw8+mBNfHtJrxuz5gbxkzQ7/Zl
aG4vxSNDc1xOMzmMfIqCSEyCZlup0uLkDy5aUhBr+2VNfFNAzHJZcgR+jgKqxniu
UR93FANzofqKd3bIV4I9sxRj1gyLJFF0JyPvYfIJyo/CNi4ePvrOuqj9CnE+EfBA
CCKAKkSOGq1mm0y86BXvSE7EFi6T4a//W0urvuHZ3/n/TveoZdcSA2du5VYiFm9S
kMSx6q4U28TsZwL7Aw2Dg/wWbwRa5L/2Ol9d//IkDfhuNOzjDLO3y6yvAiIOjuY7
Fjv0wQZT+Hywb82lKNXpogUu838w/A==
=4ZJ/
-----END PGP SIGNATURE-----

--TtKQ68UJ95PBw2X3uXia4AliN1N03Aujw--
