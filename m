From: Michal Hocko <mhocko@kernel.org>
Subject: Re: scheduling while atomic from vmci_transport_recv_stream_cb in
 3.16 kernels
Date: Thu, 14 Sep 2017 10:59:59 +0200
Message-ID: <20170914085959.nkiefbzupwmknncy@dhcp22.suse.cz>
References: <20170912090852.qshtrioffwexkslw@dhcp22.suse.cz>
 <B8A42FAB-9E16-4943-98F3-86FC8F195069@vmware.com>
 <20170913151939.gf7n6rvvjtz47tz7@dhcp22.suse.cz>
 <AA27A6E6-2376-437A-9508-FD9C2427A465@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aditya Sarwade <asarwade@vmware.com>,
        Thomas Hellstrom <thellstrom@vmware.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Masik Petr <Petr.Masik@nudz.cz>,
        Sasha Levin <alexander.levin@verizon.com>,
        Stable tree <stable@vger.kernel.org>
To: "Jorgen S. Hansen" <jhansen@vmware.com>,
        Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AA27A6E6-2376-437A-9508-FD9C2427A465@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 13-09-17 18:58:13, Jorgen S. Hansen wrote:
[...]
> The patch series look good to me.

Thanks for double checking. Ben, could you merge this to 3.16 stable
branch, please?

-- 
Michal Hocko
SUSE Labs
