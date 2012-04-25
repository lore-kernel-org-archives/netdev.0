From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at include/net/netns/generic.h:41
Date: Wed, 25 Apr 2012 18:58:55 -0400
Message-ID: <20120425225855.GA5537@redhat.com>
References: <20120328002346.GB3077@redhat.com>
 <20120402172600.GA3728@redhat.com>
 <1333390230.13718.34.camel@lade.trondhjem.org>
 <4F7DC37F.7090404@parallels.com>
 <20120405161241.GA23658@redhat.com>
 <4F7DC4CC.9080502@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F7DC4CC.9080502@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, 2012 at 08:14:04PM +0400, Stanislav Kinsbursky wrote:
 > 05.04.2012 20:12, Dave Jones =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
 > > On Thu, Apr 05, 2012 at 08:08:31PM +0400, Stanislav Kinsbursky wro=
te:
 > >
 > >   >  So, there are few questions to you, Dave:
 > >   >  1) can this happen (PipeFS mount attempt before SUNPRC module=
 insertion has
 > >   >  returned any value) in your case?
 > >
 > > I don't know enough of what systemd is doing to answer this.
 > >
 > >   >  2) how often do you experience this problem? Not every boot, =
I suppose?
 > >   >  3) And is it easy for you to reproduce?
 > >
 > > It happens most the time, but not every time.
 > >
 >=20
 > Ok, I'll send the patch soon.
 > Hope, it will help.
 >=20
 > --=20
 > Best regards,
 > Stanislav Kinsbursky

I didn't see a follow-up patch on this, and I'm still seeing the BUG in=
 rc4.

	Dave
