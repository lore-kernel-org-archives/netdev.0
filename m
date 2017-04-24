From: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH 1/2] net: dsa: b53: Add compatible strings for the Cygnus-family BCM11360.
Date: Mon, 24 Apr 2017 16:54:27 -0700
Message-ID: <8760hte4zw.fsf@eliezer.anholt.net>
References: <20170424215022.30382-1-eric@anholt.net> <20170424215022.30382-2-eric@anholt.net> <a2f4f0c9-feea-291b-dae5-f4ed10f9c547@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a2f4f0c9-feea-291b-dae5-f4ed10f9c547-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain

Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> writes:

> Minor comment in line
>
> On 17-04-24 02:50 PM, Eric Anholt wrote:
>> Cygnus is a small family of SoCs, of which we currently have
>> devicetree for BCM11360 and BCM58300.  The 11360's B53 is mostly the
>> same as 58xx, just requiring a tiny bit of setup that was previously
>> missing.
>>
>> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
>> ---
>>  Documentation/devicetree/bindings/net/dsa/b53.txt | 3 +++
>>  drivers/net/dsa/b53/b53_srab.c                    | 2 ++
>>  2 files changed, 5 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
>> index d6c6e41648d4..49c93d3c0839 100644
>> --- a/Documentation/devicetree/bindings/net/dsa/b53.txt
>> +++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
>> @@ -29,6 +29,9 @@ Required properties:
>>        "brcm,bcm58625-srab"
>>        "brcm,bcm88312-srab" and the mandatory "brcm,nsp-srab string
>>
>> +  For the BCM11360 SoC, must be:
>> +      "brcm,bcm11360-srab" and the mandatory "brcm,cygnus-srab string
>> +
> place in alphabetical order in the doc?

Moved it above BCM5310x now.  I hope that's what you meant.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlj+kDMACgkQtdYpNtH8
nujXAA//bjzJ4RnJu15b8cs0knSd99L9dkoyPYqUNVbkDBC5Qy7ZS5LLfsno8ck4
LhPDXSSS7s2zYyVwR4XfQsjNbbB7by0q9CBcdUxqAz2tf3FF4WFg7qoB/JzUWyCm
N4WIYB7f/jvlifaOaza1bPYqBVw1HihEbxRGpo+aQwf9hxmYEYN3sIS7dgIm3Oka
4Sq8tOJjq6YntgkelEBPBswqwtNVGk6mjAtxi/oQUP6QRd4ac0leqctDuKlUiQm7
gW1XDuCV8h+wxJ6QlEAo8fBKF0VZ41d6FmphNOGyiq75sWvwO7BpgwYYy56JjrYd
4RVnFIc2JsIYVoLm7EooIFWWeYu3eJGgB9xunkSOKcEakeYZHwjzWOIIvzVKAMkX
vFGdV6rIlaoDzKIoUnrr7vKlijmh0/vJxEnEZWHiTbzNhH9tWpDDPeDOuVagEXNv
nVeQnVm/GV4qBj03Em7F1PD2eLq+3memOrXUnHHDOE7N/6blCPEkmpfHye5uvQi3
zw1jtmEx1HO9inOopOwuO9J9WZ8TLJHU7ikqgERzt97KLv2CsYEsb47L8rZXasRS
GYMxccUPUX4u9rg6ngy1Syp2iaEDrO4CGTkIS1IZ7jGNPzbW8ZQTq7mRHJT234sG
6XOuMdNLwrjV+gUeye0iY5BeKCGIVnyxDJDoYMG6pVC88uqierI=
=jZYE
-----END PGP SIGNATURE-----
--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
