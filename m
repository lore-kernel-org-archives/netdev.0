From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Tue, 2 Dec 2014 14:53:50 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412021453340.7488@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
 <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no> <alpine.LNX.2.03.1412012202480.1301@gmail.com> <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com> <547D37CA.7050506@audiocodes.com> <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com> <alpine.LNX.2.03.1412020747360.1921@gmail.com> <547D6D7B.5090704@audiocodes.com> <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com> <547D7243.80508@audiocodes.com> <alpine.LNX.2.03.1412021130410.2697@gmail.com>
 <87fvcyqoup.fsf@nemi.mork.no> <alpine.LNX.2.03.1412021410270.29633@gmail.com> <87lhmqp400.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1082746179-1417528432=:7488"
Cc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87lhmqp400.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1082746179-1417528432=:7488
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Thank you very much Bjorn.


On Tue, 2 Dec 2014, Bjørn Mork wrote:

==Date: Tue, 2 Dec 2014 14:37:03
==From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==    Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==    Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
==    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
==Subject: Re: Is this 32-bit NCM?
==
==Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
==
==> ... but out of curiosity: are NCM specs allowing to change order of things in 
==> the package or not?
==> This is not to start philosofical falames or something, but to understand 
==> better how things work. And, if they do: how much arbitrarily?
==
==Only the NTB header has a fixed location. The rest can be anywhere and
==in any order. Quoting from section 3 Data Transport:
==
==  "Within any given NTB, the NTH always must be first; but the other
==   items may occur in arbitrary order."
==
==
==Bjørn
==
--8323328-1082746179-1417528432=:7488--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
