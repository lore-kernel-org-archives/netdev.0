From: Hubertus Krogmann <hk@hkit.de>
Subject: (unknown)
Date: Tue, 13 Jan 2004 21:44:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <37AE57B8-4609-11D8-8E0C-000393BE213C@hkit.de>
Mime-Version: 1.0 (Apple Message framework v609)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-md5; boundary="Apple-Mail-7--917323085"
Content-Transfer-Encoding: 7bit
Cc: c-d.hailfinger.kernel.2003@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
Subject: 
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-7--917323085
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; format=flowed

Hello

Thanx 1st for providing this forcedeth driver.

It works on my MSI nforce board
force:~ # lspci
00:00.0 Host bridge: nVidia Corporation nForce CPU bridge (rev b2)
00:00.1 RAM memory: nVidia Corporation nForce 220/420 Memory Controller 
(rev b2)
00:00.2 RAM memory: nVidia Corporation nForce 220/420 Memory Controller 
(rev b2)
00:00.3 RAM memory: nVidia Corporation nForce 420 Memory Controller 
(DDR) (rev b2)
00:01.0 ISA bridge: nVidia Corporation nForce ISA Bridge (rev c3)
00:01.1 SMBus: nVidia Corporation nForce PCI System Management (rev c1)
00:02.0 USB Controller: nVidia Corporation nForce USB Controller (rev 
c3)
00:03.0 USB Controller: nVidia Corporation nForce USB Controller (rev 
c3)
00:04.0 Ethernet controller: nVidia Corporation nForce Ethernet 
Controller (rev c2)
00:05.0 Multimedia audio controller: nVidia Corporation: Unknown device 
01b0 (rev c2)
00:06.0 Multimedia audio controller: nVidia Corporation nForce Audio 
(rev c2)
00:08.0 PCI bridge: nVidia Corporation nForce PCI-to-PCI bridge (rev c2)
00:09.0 IDE interface: nVidia Corporation nForce IDE (rev c3)
00:1e.0 PCI bridge: nVidia Corporation nForce AGP to PCI Bridge (rev b2)
01:01.0 FireWire (IEEE 1394): Texas Instruments TSB12LV26 IEEE-1394 
Controller (Link)
01:03.0 SCSI storage controller: LSI Logic / Symbios Logic 53c860 (rev 
02)
02:00.0 VGA compatible controller: nVidia Corporation NVCrush11 
[GeForce2 MX Integrated Graphics] (rev b1)

I do have a problem, my system hangs sometimes for about 5-10 seconds.
While I ping my system : no hangs
Start ping while it hangs : hang is over immediately.

That is why I will try your driver.

Anything I may test ?
Another PC w2k and a Apple iBook can be used with a SMC router with 
integrated 4 port switch...

--
Hubertus Krogmann   --  hk @ hkit . de  -- www . hkit . de
GPG Fingerprint 42 F9 76 30 C0 E6 A5 59  AE F9 DD 12 A2 29 69 2F

--Apple-Mail-7--917323085
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (Darwin)

iQEVAwUBQARYl/ME5VGxtm9BAQGwJwgAu3SMEwLKah1T2D3+BlD8OahL7aNRG1th
2nKdbcfzwlozwrLvZyQiQ+f3kGgtNRJRTo4OVXIHGyHzYKg6W8pmg/j72A0ryCZm
EWvE6ZBpyWBpcNII5HeBy3v02Cy7s7OpPefLJFAa4WnWT/Mc+js0UBOIP6gywZbz
uTPr7C8jQK0RJv4P2ernDy0gDJF3IFvyTgpqK7XGWnheelxmYz+06nMT1q9hc6s5
vh8SSrMbp0w6rNtd9JNyFTd1B7Ov8zorzsTVeMVS0FHH5sGjVpSL14OhASmGxrYE
aCxZUIhwj7er88xJBtMUGFYNW2UL2+2HRCV9+CStWb5shYbD3IqDqA==
=5BO/
-----END PGP SIGNATURE-----

--Apple-Mail-7--917323085--
