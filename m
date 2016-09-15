From: Varun Prakash <varun@chelsio.com>
Subject: Re: [net-next PATCH 00/11] iw_cxgb4,cxgbit: remove duplicate code
Date: Thu, 15 Sep 2016 20:46:30 +0530
Message-ID: <20160915151628.GA1682@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
 <CAJ3xEMi_w3nhqSpODsm=Cs42dg9w0Cu3Cc-0mZvauY7Coc+fwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
        Doug Ledford <dledford@redhat.com>,
        SWise OGC <swise@opengridcomputing.com>,
        Indranil Choudhury <indranil@chelsio.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:28751 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcIOPRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 11:17:11 -0400
Content-Disposition: inline
In-Reply-To: <CAJ3xEMi_w3nhqSpODsm=Cs42dg9w0Cu3Cc-0mZvauY7Coc+fwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Or,

On Wed, Sep 14, 2016 at 02:02:43PM +0530, Or Gerlitz wrote:
> On Tue, Sep 13, 2016 at 6:53 PM, Varun Prakash <varun@chelsio.com> wrote:
> > This patch series removes duplicate code from
> > iw_cxgb4 and cxgbit by adding common function definitions in libcxgb.
> 
> Is that bunch of misc functionalities or you can provide a more high
> level description what
> you are cleaning out. Also, what other areas are you planning to
> refactor following the review
> comments we had on the target driver?

This patch series removes duplicate function definitions
that are used in connection management.
I am looking into more improvements in connection management,
will post next series once it is ready. 

Thanks
Varun 
