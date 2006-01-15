From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: acxsm: migrate acx from homegrown 802.11 handling to softmac stack
Date: Sun, 15 Jan 2006 19:29:43 +0100
Message-ID: <200601151929.43896.carlos@cmartin.tk>
References: <200601151352.44548.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, softmac-dev@sipsolutions.net,
	acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200601151352.44548.vda@ilport.com.ua>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Sunday 15 January 2006 12:52, Denis Vlasenko wrote:
> Hi,
>=20
> http://195.66.192.167/linux/acx_patches/acxsm-20060115.tar.bz2

I've mirrored it at http://www.cmartin.tk/acx/ and will sync as with the=20
'normal' tarballs.

>=20
> README says:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> *** Not run tested. Almost certainly won't work. Lots of things are TODO.

I'll try to try it out this week. Unfortunately, my USB device is broken=20
again.
=20
> P.S. It does not mean that acx driver is discontinued.
> It will be supported as before. Let's see whether acxsm
> will get any traction at all.
             at^^^^^^^^
You mean it won't slip when the road is wet? :P
This should make certain things easier to handle, won't it? From what I've=
=20
seen you don't have to worry about fragmentation of packets. Will the stack=
=20
also handle TKPI/WPA?
=20
   cmn
=2D-=20
Carlos Mart=EDn       http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, paraphras=
ed


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
