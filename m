From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Mon, 8 May 2017 15:19:28 +0000
Message-ID: <1494256767.2591.3.camel@sandisk.com>
References: <20170504180216.7665-1-leon@kernel.org>
         <1493921453.2692.6.camel@sandisk.com> <20170506104047.GC2017@nanopsycho>
         <1494081623.3228.1.camel@sandisk.com>
         <20170507102046.GA1889@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org" <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org" <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org" <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170507102046.GA1889-6KJVSR23iU488b5SBfVpbw@public.gmane.org>
Content-Language: en-US
Content-ID: <E4E2E5BB2B4ADA4CAF36BE896F317ED3-+cFlbfsKLD6cE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-05-07 at 12:20 +0200, Jiri Pirko wrote:
> Sat, May 06, 2017 at 04:40:24PM CEST, Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org wrote:
> > On Sat, 2017-05-06 at 12:40 +0200, Jiri Pirko wrote:
> > > Thu, May 04, 2017 at 08:10:54PM CEST, Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org wrot=
e:
> > > > On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > > > > Following our discussion both in mailing list [1] and at the LPC =
2016 [2],
> > > > > we would like to propose this RDMA tool to be part of iproute2 pa=
ckage
> > > > > and finally improve this situation.
> > > >=20
> > > > Although I really appreciate your work: can you clarify why you wou=
ld like to
> > > > add *RDMA* functionality to an *IP routing* tool? I haven't found a=
ny motivation
> > > > for adding RDMA functionality to iproute2 in [1].
> > >=20
> > > Bart, please realize that iproute2 is much more than "*IP routing* to=
ol".
> > > I understand you got confused by the name. Please see sources. Your c=
omment
> > > is totally pointless...
> >=20
> > I asked for a clarification that should have been in the cover letter b=
ut that
> > was missing from that cover letter. So I think that was the right thing=
 to do
>=20
> I think that was just complete misunderstanding about what iproute2 is.

Hello Jiri,

I do not agree with your reply. The abbreviation "IP" occurs in the package
name and that is a reference to the "Internet Protocol". As far as I know
originally the iproute2 package contained only tools related to the Interne=
t
Protocol. Other tools, e.g. the tipc tool, were added later on. What I'm
wondering about is whether it really is a good idea to add tools like tipc
and rdma to the iproute2 package. The iproute2 package is so essential that
it gets installed on every Linux system, including embedded systems and
smartphones based on Linux. Several companies maintain embedded Linux
distributions and tools to build software images. These tools provide a use=
r
interface that allows to select what packages go into such an image. Adding
tools like tipc and rdma to the iproute2 package makes it harder than
necessary for those who build software images for embedded devices to
minimize the size of such an image. As you probably know even today the siz=
e
of a software image still matters for embedded devices. Something else I ha=
ve
been wondering about is whether bundling the tipc and rdma tools in the
iproute2 package will make the job harder of people who build Android ROMs?
The ip tool is present in every Android ROM, and the size of these ROMs mat=
ters
because the larger these ROMs are the less space remains for apps.

Bart.=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
