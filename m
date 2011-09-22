From: rohan puri <rohan.puri15@gmail.com>
Subject: Re: TCP_DELACK_MIN vs TCP_ATO_MIN
Date: Thu, 22 Sep 2011 09:31:24 +0530
Message-ID: <CALJfu6Ms+FyKRb18rOh7uctOYSdT6jd04tAF=t=D9xi1SiCWJg@mail.gmail.com>
References: <CAEnQRZAObcdhikY6GzG3mC1KZjgK8Xp5LzNetczmZP=BRPqN6w@mail.gmail.com>
	<CALJfu6MnV0se8YCTWt65=_4PcOhKsbvUgRmaNxbjf7La+4ar4g@mail.gmail.com>
	<CAEnQRZBdoPBn1bidga5c89n-Oru2JzrQa9bTj_tBG4HxS33PyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4691156654791954309=="
Cc: netdev@vger.kernel.org, kernelnewbies <kernelnewbies@kernelnewbies.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <kernelnewbies-bounces@kernelnewbies.org>
In-Reply-To: <CAEnQRZBdoPBn1bidga5c89n-Oru2JzrQa9bTj_tBG4HxS33PyA@mail.gmail.com>
List-Unsubscribe: <http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies>,
	<mailto:kernelnewbies-request@kernelnewbies.org?subject=unsubscribe>
List-Archive: <http://lists.kernelnewbies.org/pipermail/kernelnewbies>
List-Post: <mailto:kernelnewbies@kernelnewbies.org>
List-Help: <mailto:kernelnewbies-request@kernelnewbies.org?subject=help>
List-Subscribe: <http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies>,
	<mailto:kernelnewbies-request@kernelnewbies.org?subject=subscribe>
Sender: kernelnewbies-bounces@kernelnewbies.org
Errors-To: kernelnewbies-bounces@kernelnewbies.org
List-Id: netdev.vger.kernel.org

--===============4691156654791954309==
Content-Type: multipart/alternative; boundary=00163684829611dffb04ad7fbf67

--00163684829611dffb04ad7fbf67
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Sep 21, 2011 at 8:58 PM, Daniel Baluta <daniel.baluta@gmail.com>wrote:

> > Now the default value is of both the macros is same.
> >
> > But if you want to make delayed ack timeout configurable, then I think
> you
> > should give proc interface for TCP_DELACK_MIN.
>
> Thanks Rohan. Then also I have to export TCP_DELACK_MAX since I think
> ato cannot grow over this value.
>
> thanks,
> Daniel.
>
Yes Daniel.

Regards,
Rohan Puri

--00163684829611dffb04ad7fbf67
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Sep 21, 2011 at 8:58 PM, Daniel =
Baluta <span dir=3D"ltr">&lt;<a href=3D"mailto:daniel.baluta@gmail.com">dan=
iel.baluta@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">
<div class=3D"im">&gt; Now the default value is of both the macros is same.=
<br>
&gt;<br>
&gt; But if you want to make delayed ack timeout configurable, then I think=
 you<br>
&gt; should give proc interface for TCP_DELACK_MIN.<br>
<br>
</div>Thanks Rohan. Then also I have to export TCP_DELACK_MAX since I think=
<br>
ato cannot grow over this value.<br>
<br>
thanks,<br>
<font color=3D"#888888">Daniel.<br>
</font></blockquote></div>Yes Daniel.<br><br>Regards,<br>Rohan Puri<br>

--00163684829611dffb04ad7fbf67--


--===============4691156654791954309==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernelnewbies mailing list
Kernelnewbies@kernelnewbies.org
http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies

--===============4691156654791954309==--
