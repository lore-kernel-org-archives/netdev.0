From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 12 Sep 2016 12:05:08 -0600
Message-ID: <20160912180508.GI5843@obsidianresearch.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473696465-27986-1-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 07:07:34PM +0300, Ram Amrani wrote:
>  drivers/infiniband/hw/qedr/main.c              |  907 ++++++
>  drivers/infiniband/hw/qedr/qedr.h              |  494 ++++
>  drivers/infiniband/hw/qedr/qedr_cm.c           |  626 +++++
>  drivers/infiniband/hw/qedr/qedr_cm.h           |   61 +
>  drivers/infiniband/hw/qedr/qedr_hsi.h          |   56 +
>  drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  748 +++++
>  drivers/infiniband/hw/qedr/qedr_user.h         |   80 +

We are requiring new uAPI headers are placed under include/uapi/rdma/,
please coordinate with Leon on the path.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
