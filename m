From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Tue, 2 Dec 2014 15:04:25 +0000
Message-ID: <1417532733483.89987@audiocodes.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
 <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com>
 <874mtl55ar.fsf@nemi.mork.no>
 <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
 <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412012202480.1301@gmail.com>
 <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
 <547D37CA.7050506@audiocodes.com>
 <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com>
 <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com>
 <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
 <547D7243.80508@audiocodes.com>
 <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412021453340.7488@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.03.1412021453340.7488-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I do not understand why the wSequence matters. By the way, I think I se=
e some NDPs are right after NTH headers in the windows capture.

________________________________________
=46rom: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sent: Tuesday, December 2, 2014 21:53
To: Bj=F8rn Mork
Cc: Kevin Zhu; Eli Britstein; Alex Strizhevsky; Midge Shaojun  Tan; you=
tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: Re: Is this 32-bit NCM?

Thank you very much Bjorn.


On Tue, 2 Dec 2014, Bj=F8rn Mork wrote:

=3D=3DDate: Tue, 2 Dec 2014 14:37:03
=3D=3DFrom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
=3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
=3D=3DCc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
=3D=3D    Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
=3D=3D    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
=3D=3D    Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
=3D=3D    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
=3D=3D    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
=3D=3D    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
=3D=3DSubject: Re: Is this 32-bit NCM?
=3D=3D
=3D=3DEnrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
=3D=3D
=3D=3D> ... but out of curiosity: are NCM specs allowing to change orde=
r of things in
=3D=3D> the package or not?
=3D=3D> This is not to start philosofical falames or something, but to =
understand
=3D=3D> better how things work. And, if they do: how much arbitrarily?
=3D=3D
=3D=3DOnly the NTB header has a fixed location. The rest can be anywher=
e and
=3D=3Din any order. Quoting from section 3 Data Transport:
=3D=3D
=3D=3D  "Within any given NTB, the NTH always must be first; but the ot=
her
=3D=3D   items may occur in arbitrary order."
=3D=3D
=3D=3D
=3D=3DBj=F8rn
=3D=3D
This email and any files transmitted with it are confidential material.=
 They are intended solely for the use of the designated individual or e=
ntity to whom they are addressed. If the reader of this message is not =
the intended recipient, you are hereby notified that any dissemination,=
 use, distribution or copying of this communication is strictly prohibi=
ted and may be unlawful.

If you have received this email in error please immediately notify the =
sender and delete or destroy any copy of this message
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
