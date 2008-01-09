From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH for 2.6.24][NET] fs_enet: check for phydev existence in
	the ethtool handlers
Date: Wed, 9 Jan 2008 23:10:00 +0300
Message-ID: <8496f91a0801091210q3eda8338y74cf99382c097b41@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1592419291=="
To: linuxppc-embedded@ozlabs.org, netdev@vger.kernel.org
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1592419291==
Content-Type: multipart/alternative;
	boundary="----=_Part_11290_5481638.1199909400758"

------=_Part_11290_5481638.1199909400758
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi folks!

I had the same problem too. The solution was the following:
http://www.mail-archive.com/netdev@vger.kernel.org/msg37951.html

Also have a look at the potential multicasting recovery problem in fs_enet
driver:
http://patchwork.ozlabs.org/linuxppc/patch?id=10700

Best regards,
Matvejchikov Ilya.

------=_Part_11290_5481638.1199909400758
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi folks!<br><br>I had the same problem too. The solution was the following:<br><a href="http://www.mail-archive.com/netdev@vger.kernel.org/msg37951.html">http://www.mail-archive.com/netdev@vger.kernel.org/msg37951.html</a>
<br><br>Also have a look at the potential multicasting recovery problem in fs_enet driver:<br><a href="http://patchwork.ozlabs.org/linuxppc/patch?id=10700">http://patchwork.ozlabs.org/linuxppc/patch?id=10700</a><br><br>Best regards,
<br>Matvejchikov Ilya.<br><br>

------=_Part_11290_5481638.1199909400758--

--===============1592419291==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-embedded mailing list
Linuxppc-embedded@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-embedded
--===============1592419291==--
