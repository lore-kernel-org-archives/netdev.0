From: "Thomas D." <whissi@whissi.de>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Sat, 3 Oct 2015 21:14:16 +0200
Message-ID: <56102908.2030406@whissi.de>
References: <1443650383.13282.10.camel@daevel.fr>
 <560D1223.3070606@googlemail.com>
 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
 <560D1C5A.3050508@googlemail.com>
 <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
 <560E2994.5020400@tomt.net> <560E2F7C.4040102@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?=
	<holger.hoffstaette@googlemail.com>, Andre Tomt <andre@tomt.net>,
	Eric Dumazet <edumazet@google.com>, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <560E2F7C.4040102@googlemail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Holger Hoffst=C3=A4tte wrote:
> Greg, any chance you can drop this into the pending 4.1.10? Otherwise=
 people
> will get another broken release.

=46or me it looks like the request was too late, the patch is not inclu=
ded
in 4.1.10. So don't forget to re-apply the patch when doing the upgrade=
=2E

Greg, do you need a dedicated inclusion request for
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?=
id=3D83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
in 4.1.x or is it already on your list?


-Thomas
