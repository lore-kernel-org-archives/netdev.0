From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 6/6] vxlan: allow multiple VXLANs
 with same VNI for IPv6 link-local addresses
Date: Thu, 8 Jun 2017 20:05:06 +0200
Message-ID: <18df22e2-cbf4-e25a-b2d2-87e01281d9f4@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
	<95533e3ca4958ba2eca3efcc661713638feea220.1492187126.git.mschiffer@universe-factory.net>
	<20170414103830.111a24a8@xeon-e3>
	<3c054ae3-ec68-ab20-0928-81e313a53cde@universe-factory.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1118461983366386693=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <3c054ae3-ec68-ab20-0928-81e313a53cde-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============1118461983366386693==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="iw4JQ2UWilHTUBmLPwW1aFGT04pq62P0j"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iw4JQ2UWilHTUBmLPwW1aFGT04pq62P0j
Content-Type: multipart/mixed; boundary="mBReMgN2SIwobkmjBAfw3qa9tc9Kd8b7F";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 pshelar-LZ6Gd1LRuIk@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <18df22e2-cbf4-e25a-b2d2-87e01281d9f4-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: Re: [PATCH net-next v2 6/6] vxlan: allow multiple VXLANs with same
 VNI for IPv6 link-local addresses
References: <cover.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <95533e3ca4958ba2eca3efcc661713638feea220.1492187126.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
 <20170414103830.111a24a8@xeon-e3>
 <3c054ae3-ec68-ab20-0928-81e313a53cde-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
In-Reply-To: <3c054ae3-ec68-ab20-0928-81e313a53cde-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>

--mBReMgN2SIwobkmjBAfw3qa9tc9Kd8b7F
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/16/2017 05:15 PM, Matthias Schiffer wrote:
> On 04/14/2017 07:38 PM, Stephen Hemminger wrote:
>> On Fri, 14 Apr 2017 18:44:46 +0200
>> Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org> wrote:
>>
>>> As link-local addresses are only valid for a single interface, we can=
 allow
>>> to use the same VNI for multiple independent VXLANs, as long as the u=
sed
>>> interfaces are distinct. This way, VXLANs can always be used as a dro=
p-in
>>> replacement for VLANs with greater ID space.
>>>
>>> This also extends VNI lookup to respect the ifindex when link-local I=
Pv6
>>> addresses are used, so using the same VNI on multiple interfaces can
>>> actually work.
>>>
>>> Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
>>
>> Why does this have to be IPv6 specific?
>=20
> I'm not familar with IPv4 link-local addresses and how route lookup wor=
ks
> for them. vxlan_get_route() sets flowi4_oif to the outgoing interface; =
does
> __ip_route_output_key_hash() do the right thing for link-local addresse=
s
> when such addresses are used on multiple interfaces? I see some special=

> casing for multicast destinations, but none for link-local ones.
>=20

Getting back to this (sorry for the delay, I got caught up in other
projects), I'm seeing the following pros and cons regarding the support o=
f
VXLAN over IPv4 link-local addresses:

+ There should be no technical reason not to support it; as everything is=

in the kernel, the usual problems with IPv4 LL (userspace APIs not
supporting passing a scope ID as part of the IP address) don't apply here=


+ The code needed to support IPv4 LL should be easy to add

- IPv4 LL semantics aren't as well-defined as for IPv6. While IPv4 LL
addresses are usually in the 169.254.x.y range, the Linux kernel allows
setting the address scope independently of the range for IPv4. In contras=
t
to this, we need to judge the validity of the configuration based on
syntactic properties of the IP addresses (at least if we don't want to ad=
d
a lot of more compexity to the validation, and probably other parts of th=
e
code.) Generally, code that checks for the 169.254.x.y range is uncommon =
in
the kernel (I think I only found a single instance, somewhere in the SCTP=

implementation.)

- IPv4 LL addresses are mostly used for zeroconf; I don't really see a
usecase for zeroconf addresses + VXLANs

- Personally, I have no interest in IPv4


I probably forgot a few more arguments... All in all, I'd like the VXLAN
maintainers to decide if we do want IPv4 LL support or not, and if the
verdict is to support it, I'll implement it in the next revision of my
patchset.

Matthias


--mBReMgN2SIwobkmjBAfw3qa9tc9Kd8b7F--

--iw4JQ2UWilHTUBmLPwW1aFGT04pq62P0j--

--===============1118461983366386693==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1118461983366386693==--
