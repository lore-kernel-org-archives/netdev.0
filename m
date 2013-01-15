From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Information needed on the kernel version which
	supports ----
Date: Mon, 14 Jan 2013 22:10:28 -0800
Message-ID: <CAOaVG14kSDTcgMHcHu54iCqtEzwP35KmNN_d1KPD0_VecJvf-w@mail.gmail.com>
References: <50F3D5FD.6090608@tataelxsi.co.in>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=047d7b45070e507e1b04d34d9e5b
Cc: vyasevic@redhat.com, mst@redhat.com, netdev@vger.kernel.org,
	stephen@redhat.com, bridge@lists.linux-foundation.org,
	shmulik.ladkani@gmail.com, shemminger@vyatta.com, davem@davemloft.net
To: sandeepacs@tataelxsi.co.in
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <50F3D5FD.6090608@tataelxsi.co.in>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--047d7b45070e507e1b04d34d9e5b
Content-Type: text/plain; charset=ISO-8859-1

1. VLAN filtering in bridge is still under review, changes are requested.
Please see netdev patchwork to check for state of upcoming stuff.

2. I don't remember IGMP snooping is part of that work.



On Mon, Jan 14, 2013 at 1:55 AM, Sandeepa C S <sandeepacs@tataelxsi.co.in>wrote:

> Dear All,
>
> We are trying to add vlan support for the IGMP snooping feature in the
> kernel version 2.6.39
> But from the below thread discussion we understood that vlan support is
> already in the bridge.
> http://www.spinics.net/lists/**netdev/msg221800.html<http://www.spinics.net/lists/netdev/msg221800.html>
>
> Could you please let us know the below informations,
> 1) On what kernel version the VLAN support for multicast groups is being
> done
> 2)On what flavors it is supported, is it available with Debian
> 3)How can we get/download the supported patch files for reference.
>
> --
> Thanks & Regards,
> Sandeepa cs.
>
> Notice: The information contained in this e-mail message and/or
> attachments to it may contain confidential or privileged information. If
> you are not the intended recipient, any dissemination, use, review,
> distribution, printing or copying of the information contained in this
> e-mail message and/or attachments to it are strictly prohibited. If you
> have received this communication in error, please notify us by reply e-mail
> or telephone and immediately and permanently delete the message and any
> attachments. Thank you
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/**majordomo-info.html<http://vger.kernel.org/majordomo-info.html>
>

--047d7b45070e507e1b04d34d9e5b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">1. VLAN filtering in bridge is still under review, changes=
 are requested. Please see netdev patchwork to check for state of upcoming =
stuff.<div><br></div><div style>2. I don&#39;t remember IGMP snooping is pa=
rt of that work.=A0</div>
<div style><br></div></div><div class=3D"gmail_extra"><br><br><div class=3D=
"gmail_quote">On Mon, Jan 14, 2013 at 1:55 AM, Sandeepa C S <span dir=3D"lt=
r">&lt;<a href=3D"mailto:sandeepacs@tataelxsi.co.in" target=3D"_blank">sand=
eepacs@tataelxsi.co.in</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Dear All,<br>
<br>
We are trying to add vlan support for the IGMP snooping feature in the<br>
kernel version 2.6.39<br>
But from the below thread discussion we understood that vlan support is<br>
already in the bridge.<br>
<a href=3D"http://www.spinics.net/lists/netdev/msg221800.html" target=3D"_b=
lank">http://www.spinics.net/lists/<u></u>netdev/msg221800.html</a><br>
<br>
Could you please let us know the below informations,<br>
1) On what kernel version the VLAN support for multicast groups is being<br=
>
done<br>
2)On what flavors it is supported, is it available with Debian<br>
3)How can we get/download the supported patch files for reference.<br>
<br>
--<br>
Thanks &amp; Regards,<br>
Sandeepa cs.<br>
<br>
Notice: The information contained in this e-mail message and/or attachments=
 to it may contain confidential or privileged information. If you are not t=
he intended recipient, any dissemination, use, review, distribution, printi=
ng or copying of the information contained in this e-mail message and/or at=
tachments to it are strictly prohibited. If you have received this communic=
ation in error, please notify us by reply e-mail or telephone and immediate=
ly and permanently delete the message and any attachments. Thank you<br>

<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe netdev&quot;=
 in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org" targe=
t=3D"_blank">majordomo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/<u></u>majordomo-info.html</=
a><br>
</blockquote></div><br></div>

--047d7b45070e507e1b04d34d9e5b--
