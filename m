From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] IB/hfi1: use pcie_flr instead of duplicating it
Date: Tue, 25 Apr 2017 13:00:03 -0400
Message-ID: <1493139603.3041.74.camel@redhat.com>
References: <20170414191131.14286-1-hch@lst.de>
         <20170414191131.14286-6-hch@lst.de>
         <A33E225544E47D4DB5713032774B132783960382@irsmsx105.ger.corp.intel.com>
         <20170424143507.GA28812@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "Cabiddu, Giovanni" <giovanni.cabiddu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Benedetto, Salvatore" <salvatore.benedetto-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Marciniszyn, Mike" <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Dalessandro, Dennis" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Satanand Burla <satananda.burla-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavayi-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        qat-linux <qat-linux-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "li
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        "Byczkowski, Jakub" <jakub.byczkowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170424143507.GA28812-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-24 at 16:35 +0200, Christoph Hellwig wrote:
> On Mon, Apr 24, 2017 at 02:16:31PM +0000, Byczkowski, Jakub wrote:
> > 
> > Tested-by: Jakub Byczkowski <jakub.byczkowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Are you (and Doug) ok with queueing this up in the PCI tree?

I'm fine with that.  Feel free to add my Acked-by to the hfi1 patch.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
