From: "Alexander Zapatka" <alexzapatka@hotmail.com>
Subject: Re: suggested forcedeth updates....
Date: Wed, 19 Nov 2003 10:06:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY2-F153s0m7nz605N0001807b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rask@sygehus.dk, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

thats a great idea!  except i dont know how to implement it in a patch :)=
 =20
hope it makes it in to the next version.



      -o)
      /\\    Message void if penguin violated
     _\_V    Don't mess with the penguin






----Original Message Follows----
From: Rask Ingemann Lambertsen <rask@sygehus.dk>
To: Alexander Zapatka <alexzapatka@hotmail.com>
CC: netdev@oss.sgi.com
Subject: Re: suggested forcedeth updates....
Date: Wed, 19 Nov 2003 12:48:45 +0100
MIME-Version: 1.0
Received: from 0x50a14406.albnxx15.adsl-dhcp.tele.dk ([80.161.68.6]) by=20
mc7-f27.hotmail.com with Microsoft SMTPSVC(5.0.2195.6713); Wed, 19 Nov 20=
03=20
03:51:36 -0800
Received: by 0x50a14406.albnxx15.adsl-dhcp.tele.dk (Postfix, from userid=20
500)id A24BC42B3; Wed, 19 Nov 2003 12:48:45 +0100 (CET)
X-Message-Info: JGTYoYF78jH14zHqGtQ8WJps3LyBHhOo
Message-ID: <20031119124845.B7622@sygehus.dk>
References: <BAY2-F101QTmReozTIA0001027c@hotmail.com>
User-Agent: Mutt/1.2.5.1i
In-Reply-To: <BAY2-F101QTmReozTIA0001027c@hotmail.com>; from=20
alexzapatka@hotmail.com on Mon, Nov 17, 2003 at 11:07:15PM -0500
Return-Path: rask@sygehus.dk
X-OriginalArrivalTime: 19 Nov 2003 11:51:53.0303 (UTC)=20
FILETIME=3D[864B8E70:01C3AE93]

On Mon, Nov 17, 2003 at 11:07:15PM -0500, Alexander Zapatka wrote:

 > that way you can modprobe/insmod with debug=3D1 and debuging works... =
or=20
you
 > can just load it, or load it with debug=3D0 and no debuging info is=20
printed.
 >
 > just thought it might be a nice addition.

Even better would be to use the NETIF_MSG_* flags defined in
linux/netdevice.c and to be able to use ethtool to change the setting at
runtime.

--
Regards,
Rask Ingemann Lambertsen

_________________________________________________________________
Say =93goodbye=94 to busy signals and slow downloads with a high-speed In=
ternet=20
connection! Prices start at less than $1 a day average. =20
https://broadband.msn.com (Prices may vary by service area.)
