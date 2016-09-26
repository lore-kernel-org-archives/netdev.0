From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Mon, 26 Sep 2016 10:51:04 -0600
Message-ID: <20160926165104.GA12011@obsidianresearch.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <20160925070352.GU4088@leon.nu>
 <9f65ab5c-d8c2-e8e3-9334-5d1865a20dc9@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org,
        bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9f65ab5c-d8c2-e8e3-9334-5d1865a20dc9-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 25, 2016 at 10:25:12PM -0700, Adit Ranadive wrote:
> > As Jason said, you need a very good reason to split and create number of
> > files per-driver in UAPI folder.
> 
> I can move the pvrdma-uapi.h back to the pvrdma driver folder.

Just don't copy any of the content into your user space provider.

Thanks
Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
