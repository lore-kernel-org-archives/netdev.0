From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 08/19] scsi: be2iscsi: Replace PCI pool old API
Date: Fri, 3 Mar 2017 12:30:03 +0300
Message-ID: <d73deb0f-fd69-a357-ee6d-6edd62197666@cogentembedded.com>
References: <20170301155521.30281-1-romain.perier@collabora.com>
 <20170301155521.30281-9-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:32963 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdCCJ55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 04:57:57 -0500
Received: by mail-lf0-f54.google.com with SMTP id a6so45160381lfa.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 01:57:32 -0800 (PST)
In-Reply-To: <20170301155521.30281-9-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2017 6:55 PM, Romain Perier wrote:

> The PCI pool API is deprecated. This commits replaces the PCI pool old

    Commit.

> API by the appropriated function with the DMA pool API.

    Appropriate perhaps?

> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
[...]

MBR, Sergei
