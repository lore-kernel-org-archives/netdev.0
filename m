From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] ACX: swap netdevice_t for struct net_device
Date: Sun, 15 Jan 2006 13:06:57 +0200
Message-ID: <200601151306.57824.vda@ilport.com.ua>
References: <200601150043.34890.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200601150043.34890.carlos@cmartin.tk>
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

On Sunday 15 January 2006 01:43, Carlos Mart=EDn wrote:
> Hi,
>=20
>  Does netdevice_t serve any actual purpose now? It used to be for 2.2/2.4=
=20
> compatibility, but we don't have that anymore.
>=20
>  Attached patch does a s/netdevice_t/struct net_device/g on all the files=
 that=20
> required it. It's against 20060114

Too late :)
acx-20060115 already has no netdevice_t.
=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
