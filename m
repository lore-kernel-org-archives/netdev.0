From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: v6: faster tree-based sysctl implementation
Date: Wed, 07 Dec 2011 16:19:53 -0800
Message-ID: <m162hrgbiu.fsf@fess.ebiederm.org>
References: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com>
	<CAJL_dMtgP+BqFn3aGVBbGDJ+kMyGiEC_NmDURzh4mU=Jo=qZVA@mail.gmail.com>
	<CAPLs8y8vhioqc3CPrD7ugmVkR2DjKWNm8+T5j9QQnrxi=BgvdA@mail.gmail.com>
	<CAJL_dMtvgnZHH0uLE3j7Mg2Xqwt2rd90Uy0pUxm6muPmjFbkQg@mail.gmail.com>
	<CAJL_dMvbL0LBrJ4irP3vd_PA458i0YefWpmvMgphuT+TnF2O5Q@mail.gmail.com>
	<CAPLs8y-sc7CZw2Yb11A-jTEMmTYva==XHgCqK1UmWN6_HX0rfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anca Emanuel <anca.emanuel@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPLs8y-sc7CZw2Yb11A-jTEMmTYva==XHgCqK1UmWN6_HX0rfA@mail.gmail.com>
	(Lucian Adrian Grijincu's message of "Wed, 7 Dec 2011 03:44:29 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucian Adrian Grijincu <lucian.grijincu@gmail.com> writes:

> On Wed, Dec 7, 2011 at 2:08 AM, Anca Emanuel <anca.emanuel@gmail.com>=
 wrote:
>> You can ask Stephen Rothwell to include your tree in next.
>> git://github.com/luciang/linux-2.6-new-sysctl.git =C2=A0v6-new-sysct=
l-alg
>
>
> Thank you Anca, but I don't want to pollute Stephen's linux-next tree=
 ATM.
> I'd wait until a maintainer chimes in and agrees that this approach i=
s
> sound.

Which is my cue to say that I am behind the power curve in reviewing
this.  I will see if I can get to this before the end of the week.

Doing this and getting it right is definitely something we need to do.

We do need to be careful so that the code we wind up with is not just
faster but more maintainable than what we have today.

Thanks for still pushing this,

Eric
