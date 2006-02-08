From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acxsm: Add _{get,set}_encodeext and improve logging in _encode
Date: Wed, 8 Feb 2006 11:47:54 +0200
Message-ID: <200602081147.54843.vda@ilport.com.ua>
References: <200602072104.39208.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200602072104.39208.carlos@cmartin.tk>
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

On Tuesday 07 February 2006 22:04, Carlos Mart=C3=ADn wrote:
> Content-Transfer-Encoding: quoted-printable

Patch was damaged. I think sending them as plain-text attachment
would work better.

>     Add _{get,set}_encodeext and improve logging in _encode
>    =20
>     The code in _{get,set}_encode has been reordered a bit so we have
>     better logging (function entry and exit) and _{get,set}_encodeext have
>     been implemented as a wrapper for the ieee80211 stack functions.

Applied, thanks!

=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
