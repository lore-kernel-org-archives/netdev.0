From: Michal Hocko <mhocko@kernel.org>
Subject: Re: scheduling while atomic from vmci_transport_recv_stream_cb in
 3.16 kernels
Date: Mon, 18 Sep 2017 08:11:37 +0200
Message-ID: <20170918061137.7o3ogbce6ap3jn3o@dhcp22.suse.cz>
References: <20170912090852.qshtrioffwexkslw@dhcp22.suse.cz>
 <B8A42FAB-9E16-4943-98F3-86FC8F195069@vmware.com>
 <20170913151939.gf7n6rvvjtz47tz7@dhcp22.suse.cz>
 <AA27A6E6-2376-437A-9508-FD9C2427A465@vmware.com>
 <20170914085959.nkiefbzupwmknncy@dhcp22.suse.cz>
 <1505495535.2825.41.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        Thomas Hellstrom <thellstrom@vmware.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Masik Petr <Petr.Masik@nudz.cz>,
        Sasha Levin <alexander.levin@verizon.com>,
        Stable tree <stable@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1505495535.2825.41.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 15-09-17 18:12:15, Ben Hutchings wrote:
> On Thu, 2017-09-14 at 10:59 +0200, Michal Hocko wrote:
> > On Wed 13-09-17 18:58:13, Jorgen S. Hansen wrote:
> > [...]
> > > The patch series look good to me.
> > 
> > Thanks for double checking. Ben, could you merge this to 3.16 stable
> > branch, please?
> 
> I have a long list of requests to work through, but I will get to this
> eventually.

Thanks!
-- 
Michal Hocko
SUSE Labs
