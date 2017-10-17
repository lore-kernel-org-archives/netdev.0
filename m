From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v2 00/15] make structure field, function arguments and
 structures const
Date: Tue, 17 Oct 2017 12:16:18 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1710171216060.5035@hadrien>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <20171017101245.GA4646@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, laurent.pinchart@ideasonboard.com,
        jlbec@evilplan.org, ccaulfie@redhat.com, teigland@redhat.com,
        mfasheh@versity.com, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-iio@vger.kernel.org,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-nvme@lists.infradead.org, linux-pci@vger.kernel.org,
        linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
        linux-usb@vger.kernel.org, cluster-de
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:14880 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756552AbdJQKQY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 06:16:24 -0400
In-Reply-To: <20171017101245.GA4646@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 17 Oct 2017, Greg KH wrote:

> On Mon, Oct 16, 2017 at 05:18:39PM +0200, Bhumika Goyal wrote:
> > Make the ci_type field and some function arguments as const. After this
> > change, make config_item_type structures as const.
> >
> > * Changes in v2- Combine all the followup patches and the constification
> > patches into a series.
>
> Who do you want to take these patches?  If you want, I can take them
> through my driver-core tree, which has done other configfs stuff like
> this in the past.

Christoph Hellwig proposed to take care of it.

julia



>
> thanks,
>
> greg k-h
>
