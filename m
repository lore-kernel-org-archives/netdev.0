From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 3.0 released
Date: Sat, 06 Aug 2011 12:58:57 +0100
Message-ID: <1312631937.2591.975.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-BHsMCPVo3xPIJpTAdHO5"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38333 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752544Ab1HFL7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 07:59:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BHsMCPVo3xPIJpTAdHO5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.0 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.0.tar.gz

Release notes:

        * Feature: Report supported pause frame modes
        * Feature: Support firmware dump (-w and -W options)
        * Feature: Report advertised and supported 20G link modes
        * Feature: Add an 'l4data' option for ip4 filters (-U option)
        * Fix: Correct swapped h_source and h_dest fields for ether filters
          (-U option)
        * Fix: Set ip_ver field correctly for ip4 filters (-U option)
        * Fix: Correct parameter validation for -e and -E options; in
          particular, treat the 'magic' value as unsigned

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-BHsMCPVo3xPIJpTAdHO5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATj0sgOe/yOyVhhEJAQo1zBAA0wqHsH4W0bW0BxVTBbhcPZ9yApIrzKZh
JzVRD0w0H1RcOuWiQ0iCbWxVb+VHlFuyrPjw0iCJB4tD2bB6h2/vIM9jDzaoRl3U
AJqzlv04BoX/7KO7UmomjbihDsPEmIC4j+/aQcYgxHkWYtetBi5K92i0aNx66CT2
xkqXgWcZzaupznC8F8teFrSUs6h+9njfzLXAPobV8l/UHm5NKAyzFmxw2xRt+nW4
mMLgIjCAsw1X0N54BaatjoSW/ZUWipwSk6Lyob24/HMPG936WNGfzO9WU32cv7++
hfx9W7mehXn3fmViJUXBspWxg57V2IRkWVKg0HTCzL7lAktElSouJtf1GjEHXZHX
3UvDoAznkg4lEfDkZlzqeRiugXmndJmgCcHnpzrDWvl2TuhLKOoP1si8dKAHC0Vk
/QKbZGgFKPI20d9MVSmhTWehQedyoNcueDbcYTEzQCQb2zpeVJT45pUuxA96yYh/
VdPqamjSMPayxXeuAR+KO7SwZv0/I1EakdsFZKs+IxvYy6dHO7nQ7+nJ3NE7SfNY
hCzix/1OrHT5uMqDfIlRnUPVdSA1gggYc/PADIrPCzQbF5e1iBhDdE8ibq0tTKqV
i2Un6u6KycJWPZuhwGpE1O6Rb1KEuUS22XOL9LR7FnTCvPLLrZZrigtIJfZ4G4mz
3ku645MJwh0=
=7JQh
-----END PGP SIGNATURE-----

--=-BHsMCPVo3xPIJpTAdHO5--
