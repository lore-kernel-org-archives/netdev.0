From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 20:14:01 -0800
Message-ID: <20161216041401.GA91111@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215165611.GB3264@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161215165611.GB3264-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 09:56:11AM -0700, Jason Gunthorpe wrote:
>On Wed, Dec 14, 2016 at 11:59:32PM -0800, Vishwanathapura, Niranjana wrote:
>>  create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Kconfig
>>  create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Makefile
>
>Stil NAK on these paths, I already explained why 'sw' is totally
>unsuitable. Put it in drivers/net or drivers/infiniband/ulp
>

I understand. I did not want to change dirver location until we concenses
on where it belongs.
In next revision, I will move it under drivers/infiniband/ulp/hfi_vnic.
If anybody thinks it should be in a different folder, let me know.

Niranjana

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
