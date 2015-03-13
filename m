From: Saurabh Pal <saurabh6321@gmail.com>
Subject: ath9k channel switch
Date: Fri, 13 Mar 2015 12:32:38 +0530
Message-ID: <CAGrUaU24vCH6+GpAtBCNiGwdT4_-FNNLDq=_s5zhSPBOp8bbmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0283576248=="
Cc: netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	ath9k-devel@qca.qualcomm.com
To: linux-wireless@vger.kernel.org
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
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

--===============0283576248==
Content-Type: multipart/alternative; boundary=047d7b5d22b0faf4d60511261593

--047d7b5d22b0faf4d60511261593
Content-Type: text/plain; charset=UTF-8

Hi all,

Just wanted to know whether it is possible to switch the channel without
resetting the chip. Also if possible can anybody tell me how much time it
takes to switch the channel by resetting the chip?

Quoting from the driver:

>/* Set/change channels.  If the channel is really being changed, it's done
> * by reseting the chip.  To accomplish this we must first cleanup any
pending
> * DMA, then restart stuff.
>*/
>static int ath_set_channel(struct ath_softc *sc)


Regards,
Saurabh

--047d7b5d22b0faf4d60511261593
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi all,<div><br></div><div>Just wanted to know whether it =
is possible to switch the channel without resetting the chip. Also if possi=
ble can anybody tell me how much time it takes to switch the channel by res=
etting the chip?</div><div><br></div><div>Quoting from the driver:</div><di=
v><div><br></div><div>&gt;/* Set/change channels.=C2=A0 If the channel is r=
eally being changed, it&#39;s done</div><div>&gt; * by reseting the chip.=
=C2=A0 To accomplish this we must first cleanup any pending</div><div>&gt; =
* DMA, then restart stuff.</div><div>&gt;*/</div></div><div>&gt;static int =
ath_set_channel(struct ath_softc *sc)<br></div><div><br></div><div><br></di=
v><div>Regards,</div><div>Saurabh</div></div>

--047d7b5d22b0faf4d60511261593--

--===============0283576248==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============0283576248==--
