From: Norbert Preining <preining@logic.at>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel
	PRO/Wireless 3945ABG
Date: Sat, 10 Feb 2007 01:46:20 +0100
Message-ID: <20070210004620.GA5959@gamma.logic.tuwien.ac.at>
References: <45CCE3CA.4050904@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ipw3945-devel@lists.sourceforge.net
To: James Ketrenos <jketreno@linux.intel.com>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <45CCE3CA.4050904@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi all!

On Fre, 09 Feb 2007, James Ketrenos wrote:
> We are pleased to announce the availability of a new driver for the =

> Intel PRO/Wireless 3945ABG Network Connection adapter.  This new driver =


I am impressed: I had 2.6.20 running with ipw3945 + wpa_supplicant. I
installed the d80211 system and the new driver, rebooted, and you won't
believe it, I had network connection even with WEP encryption.

That was a big surprise for me that it worked out of the box without any
magic.

If you are interested in any dmesg/log output, please let me know.


Ahhh ... one thing: The LED on my Acer Laptop (TM3012) does not show up,
maybe because I have CONFIG_D80211_LEDS off?

Again, thanks a lot for the good work!

Norbert

---------------------------------------------------------------------------=
----
Dr. Norbert Preining <preining@logic.at>                    Universit=E0 di=
 Siena
Debian Developer <preining@debian.org>                         Debian TeX G=
roup
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 =
B094
---------------------------------------------------------------------------=
----
HARPENDEN (n.)
The coda to a phone conversion, consisting of about eight exchanges,
by which people try gracefully to get off the line.
			--- Douglas Adams, The Meaning of Liff

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
