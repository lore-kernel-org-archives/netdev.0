From: Saurabh Pal <saurabh6321@gmail.com>
Subject: Re: ath9k channel switch
Date: Wed, 8 Apr 2015 13:11:12 +0530
Message-ID: <CAGrUaU1D_tO9+HrH_mEa0U13xTCuOijyvcn2_mi8cUgkkPeOuw@mail.gmail.com>
References: <CAGrUaU24vCH6+GpAtBCNiGwdT4_-FNNLDq=_s5zhSPBOp8bbmg@mail.gmail.com>
	<21764.61660.411242.223378@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1568406355=="
Cc: netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, ath9k-devel@qca.qualcomm.com
To: Sujith Manoharan <sujith@msujith.org>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <21764.61660.411242.223378@gargle.gargle.HOWL>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Mime-version: 1.0
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

--===============1568406355==
Content-Type: multipart/alternative; boundary=f46d0443041ec418b3051331a724

--f46d0443041ec418b3051331a724
Content-Type: text/plain; charset=UTF-8

Hi,
 Thanks for the reply sujith. Just wanted to know if the function
'ath9k_hw_do_fastcc()' can be used directly or I need to consider
somethings before using it.

Saurabh

On Sun, Mar 15, 2015 at 8:09 AM, Sujith Manoharan <sujith@msujith.org>
wrote:

> Saurabh Pal wrote:
> > Just wanted to know whether it is possible to switch the channel without
> > resetting the chip. Also if possible can anybody tell me how much time it
> > takes to switch the channel by resetting the chip?
>
> Fast Channel Change is used to switch channels without a full chip reset.
> The time taken to switch channels is not exported, but you can measure it
> in the driver.
>
> Sujith
>

--f46d0443041ec418b3051331a724
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,=C2=A0<div>=C2=A0Thanks for the reply sujith. Just want=
ed to know if the function &#39;ath9k_hw_do_fastcc()&#39; can be used direc=
tly or I need to consider somethings before using it.</div><div><br></div><=
div>Saurabh</div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Sun, Mar 15, 2015 at 8:09 AM, Sujith Manoharan <span dir=3D"ltr">&lt;<a =
href=3D"mailto:sujith@msujith.org" target=3D"_blank">sujith@msujith.org</a>=
&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">Saura=
bh Pal wrote:<br>
&gt; Just wanted to know whether it is possible to switch the channel witho=
ut<br>
&gt; resetting the chip. Also if possible can anybody tell me how much time=
 it<br>
&gt; takes to switch the channel by resetting the chip?<br>
<br>
</span>Fast Channel Change is used to switch channels without a full chip r=
eset.<br>
The time taken to switch channels is not exported, but you can measure it<b=
r>
in the driver.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Sujith<br>
</font></span></blockquote></div><br></div></div>

--f46d0443041ec418b3051331a724--

--===============1568406355==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============1568406355==--
