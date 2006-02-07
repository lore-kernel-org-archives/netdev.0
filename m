From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acxsm: Change acx_ioctl_{get,set}_encode to use softmac
Date: Tue, 7 Feb 2006 08:20:19 +0200
Message-ID: <200602070820.19239.vda@ilport.com.ua>
References: <200602070033.02698.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200602070033.02698.carlos@cmartin.tk>
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

On Tuesday 07 February 2006 01:32, Carlos Mart=EDn wrote:
> Hi,
>=20
>  The attached patch changes the acx_ioctl_{get,set}_encode functions to u=
se=20
> the 80211 stack in the kernel, so they become mere wrappers.
>=20
> Signed-off-by: Carlos Martin <carlos@cmartin.tk>
>=20
>    cmn

Applied, thanks!
=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
