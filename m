From: Mike Keehan <mike_keehan@yahoo.com>
Subject: Re: e100 NETDEV WATCHDOG transmit timeout since 2.6.4
Date: Tue, 20 Apr 2004 09:08:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040420160806.33161.qmail@web12305.mail.yahoo.com>
References: <20040420155903.GA16152@zarquon.at.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20040420155903.GA16152@zarquon.at.home>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am getting these too in recent kernels, but only on a
10Mhz half-duplex network. I have to manually down
and up the interface to recover.

On a 100Mhz switched network, the e100 is OK (at least 12hours+).

Mike.

NETDEV WATCHDOG: eth0: transmit timed out
--- Mike@Keehan.net wrote:
> ----- Forwarded message from Eamonn Hamilton
> <EAMONN.HAMILTON@saic.com> -----
>=20
> Subject: e100 NETDEV WATCHDOG transmit timeout since 2.6.4
> From: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
> To: linux-kernel@vger.kernel.org
> Date: Tue, 20 Apr 2004 10:13:33 +0100
>=20
> Hi,
>=20
> Since 2.6.4 my ethernet interface is timing out after successfully
> operating for 30 minutes or so, and is reset by the watchdog and runs
> for another 30 minutes or so. This behaviour is only since 2.6.4 when
> I
> believe a rewrite of the code was done. I've tried it with acpi
> disabled, and got the same results if this helps.
>=20
> Anybody got any ideas?
>=20
> Cheers,
> Eamonn
> --=20
> Eamonn Hamilton <hamiltonea@uk-aberdeen.mail.saic.com>
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20
>=20
> ----- End forwarded message -----



=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
