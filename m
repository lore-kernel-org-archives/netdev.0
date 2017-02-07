From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 7 Feb 2017 21:28:59 +0000
Message-ID: <1486502926.2581.4.camel@sandisk.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org"
        <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Content-ID: <199F42699B90AA4293882924A97DE604-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-07 at 12:22 -0800, Vishwanathapura, Niranjana wrote:
> Intel Omni-Path Host Fabric Interface (HFI) Virtual Network Interface
> Controller (VNIC) feature supports Ethernet functionality over Omni-Path
> fabric by encapsulating the Ethernet packets between HFI nodes.

This may have been stated before, but what is missing from this description
is an explanation of why accepting an Ethernet over RDMA driver in the
upstream kernel is considered useful. We already have an IPoIB driver, so
why to add another driver to the kernel tree for communicating IP packets
over an RDMA network?

Bart.--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
