From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH 01/11] linux/time64.h:Introduce the 'struct itimerspec64'
 for 64bit
Date: Mon, 20 Apr 2015 18:55:32 +0800
Message-ID: <CAMz4kuJ+Kh++H1O9YSYjV+dz9fCXHP7uqbkmN0qjqNp+Rcr86w@mail.gmail.com>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <1429509459-17068-2-git-send-email-baolin.wang@linaro.org>
 <5534CB9D.1080600@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5733674424914077835=="
Cc: pang.xunlei@linaro.org, peterz@infradead.org, heiko.carstens@de.ibm.com,
 paulus@samba.org, cl@linux.com, heenasirwani@gmail.com,
 linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
 y2038 Mailman List <y2038@lists.linaro.org>, rafael.j.wysocki@intel.com,
 ahh@google.com, fweisbec@gmail.com, pjt@google.com, riel@redhat.com,
 Arnd Bergmann <arnd@arndb.de>, Richard Cochran <richardcochran@gmail.com>,
 schwidefsky@de.ibm.com, John Stultz <john.stultz@linaro.org>,
 Thomas Gleixner <tglx@linutronix.de>, rth@twiddle.net,
 gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <5534CB9D.1080600@cogentembedded.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============5733674424914077835==
Content-Type: multipart/alternative; boundary=089e0122f074d7efa6051425c45d

--089e0122f074d7efa6051425c45d
Content-Type: text/plain; charset=UTF-8

On 20 April 2015 at 17:49, Sergei Shtylyov <
sergei.shtylyov@cogentembedded.com> wrote:

> Hello.
>
> On 4/20/2015 8:57 AM, Baolin Wang wrote:
>
>  This patch introduces the 'struct itimerspec64' for 64bit to replace
>> itimerspec,
>> and also introduces the conversion methods: itimerspec64_to_itimerspec()
>> and
>> itimerspec_to_itimerspec64(), that makes itimerspec to ready for 2038
>> year.
>>
>
>    "To" not needed here.
>
>  Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
>>
>
> [...]
>
> WBR, Sergei
>
>
Hi Sergei,

Sorry for the mistake. Thank you for your comments. I'll fix that in next
patch.


-- 
Baolin.wang
Best Regards

--089e0122f074d7efa6051425c45d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On 20 April 2015 at 17:49, Sergei Shtylyov <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:sergei.shtylyov@cogentembedded.com" target=3D"_blank">sergei.sh=
tylyov@cogentembedded.com</a>&gt;</span> wrote:<br><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex">Hello.<span class=3D""><br>
<br>
On 4/20/2015 8:57 AM, Baolin Wang wrote:<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
This patch introduces the &#39;struct itimerspec64&#39; for 64bit to replac=
e itimerspec,<br>
and also introduces the conversion methods: itimerspec64_to_itimerspec() an=
d<br>
itimerspec_to_itimerspec64(), that makes itimerspec to ready for 2038 year.=
<br>
</blockquote>
<br></span>
=C2=A0 =C2=A0&quot;To&quot; not needed here.<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Signed-off-by: Baolin Wang &lt;<a href=3D"mailto:baolin.wang@linaro.org" ta=
rget=3D"_blank">baolin.wang@linaro.org</a>&gt;<br>
</blockquote>
<br>
[...]<br>
<br>
WBR, Sergei<br>
<br>
</blockquote></div><div class=3D"gmail_extra"><br></div>Hi Sergei,</div><di=
v class=3D"gmail_extra"><br></div><div class=3D"gmail_extra">Sorry for the =
mistake. Thank you for your comments. I&#39;ll fix that in next patch.<br><=
br clear=3D"all"><div><br></div>-- <br><div class=3D"gmail_signature"><div =
dir=3D"ltr"><div>Baolin.wang<br></div>Best Regards<br></div></div>
</div></div>

--089e0122f074d7efa6051425c45d--

--===============5733674424914077835==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============5733674424914077835==--
