From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [RFC,v3,12/12] fsl/fman: Add FMan MAC driver
Date: Mon, 20 Jul 2015 13:33:29 +0000
Message-ID: <BL2PR03MB545971A75540877E4B4FFD3E6850@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1430299742-29428-1-git-send-email-igal.liberman@freescale.com>
	 <1437394575.10831.18.camel@transmode.se>
	 <BL2PR03MB5450DB021D160D507432FC5E6850@BL2PR03MB545.namprd03.prod.outlook.com>
 <1437397042.10831.34.camel@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liberman Igal <Igal.Liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437397042.10831.34.camel@transmode.se>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> Sent: Monday, July 20, 2015 3:57 PM
> To: netdev@vger.kernel.org; Liberman Igal-B31950; Bucur Madalin-Cristian-
> B32716
> Cc: linuxppc-dev@lists.ozlabs.org; linux-kernel@vger.kernel.org
> Subject: Re: [RFC,v3,12/12] fsl/fman: Add FMan MAC driver
> 
> On Mon, 2015-07-20 at 12:28 +0000, Madalin-Cristian Bucur wrote:
> > Hi Joakim,
> >
> > It seems we just need to align to the API introduced by Thomas Petazzoni
> > in 3be2a49e.
> >
> > Madalin
> 
> So it seems, any idea when the next spin will be ready?
> Could you also push it onto
>   http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git/
> ?
> 
>  Jocke

We're working on addressing all the feedback received to date (you've just added
a bit more) then we'll re-submit the FMan driver together with the DPAA Ethernet
driver. A push in the public git is also going to take place after the patches are sent
for review.

Madalin
