From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: [PATCH] ACX: swap netdevice_t for struct net_device
Date: Sun, 15 Jan 2006 12:54:23 +0100
Message-ID: <200601151254.24145.carlos@cmartin.tk>
References: <200601150043.34890.carlos@cmartin.tk> <200601151306.57824.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200601151306.57824.vda@ilport.com.ua>
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

On Sunday 15 January 2006 12:06, Denis Vlasenko wrote:
> On Sunday 15 January 2006 01:43, Carlos Mart=EDn wrote:
> >  Attached patch does a s/netdevice_t/struct net_device/g on all the fil=
es=20
that=20
> > required it. It's against 20060114
>=20
> Too late :)
> acx-20060115 already has no netdevice_t.

Can you read my mind? :) I see you also got rid of wlandevice_t, nice.

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
