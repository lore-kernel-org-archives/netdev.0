From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 01/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) documentation
Date: Wed, 22 Feb 2017 23:24:12 -0800
Message-ID: <20170223072412.GA57966@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-2-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486573231.16026.1.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1486573231.16026.1.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 05:00:45PM +0000, Bart Van Assche wrote:
>On Tue, 2017-02-07 at 12:23 -0800, Vishwanathapura, Niranjana wrote:
>
>Please elaborate this section. What is a virtual Ethernet switch? Is it a
>software entity or something that is implemented in hardware? Also, how are
>these independent Ethernet networks identified on the wire? The Linux kernel
>already supports IB partitions and Ethernet VLANs. How do these independent
>Ethernet networks compare to IB partitions and Ethernet VLANs? Which wire-
>level header contains the identity of these Ethernet networks? Is it
>possible to query from user space which Ethernet network a VNIC belongs to?
>If so, with which API and which tools?
>

I have added the VNIC packet format and some related information to the 
documentation in the PATCH series I just sent out.

>Thanks,
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
