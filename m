From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH 00/11] iw_cxgb4,cxgbit: remove duplicate code
Date: Wed, 14 Sep 2016 11:32:43 +0300
Message-ID: <CAJ3xEMi_w3nhqSpODsm=Cs42dg9w0Cu3Cc-0mZvauY7Coc+fwg@mail.gmail.com>
References: <cover.1473781521.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, indranil-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2016 at 6:53 PM, Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wrote:
> This patch series removes duplicate code from
> iw_cxgb4 and cxgbit by adding common function definitions in libcxgb.

Is that bunch of misc functionalities or you can provide a more high
level description what
you are cleaning out. Also, what other areas are you planning to
refactor following the review
comments we had on the target driver?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
