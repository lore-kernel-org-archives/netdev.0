From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Fri, 2 Dec 2016 10:58:48 +0100
Message-ID: <20161202095848.GA14586@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
 <20161130184511.GB8209@netboy>
 <875d4cc2-8a47-b06d-fb46-0cacc28dbaee@ti.com>
 <20161130221738.GA13099@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161130221738.GA13099@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2016 at 11:17:38PM +0100, Richard Cochran wrote:
> On Wed, Nov 30, 2016 at 02:43:57PM -0600, Grygorii Strashko wrote:
> > Sry, but this is questionable - code for pps comes from TI internal
> > branches (SDK releases) where it survived for a pretty long time.

Actually, there is a way to get an accurate PPS from the am335x.  See
this recent thread:

   https://www.mail-archive.com/linuxptp-devel@lists.sourceforge.net/msg01726.html

That is the way to go, and so, please drop this present patch.

Thanks,
Richard
