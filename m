From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: Re: [PATCH net-next v3 1/2] pci: Add Cavium PCI vendor id
Date: Mon, 18 May 2015 14:00:22 -0700
Message-ID: <555A52E6.8010408@auriga.com>
References: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com> <1431747401-20847-2-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nn-mx.auriga.ru ([81.19.133.66]:44950 "EHLO nn-mx.auriga.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbbERVAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 17:00:38 -0400
In-Reply-To: <1431747401-20847-2-git-send-email-aleksey.makarov@auriga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Author of this patch is

Author: Sunil Goutham <sgoutham@cavium.com>

Sorry for this.  It will be fixed in next versions.

On 05/15/2015 08:36 PM, Aleksey Makarov wrote:
> Signed-off-by: Aleksey Makarov <aleksey.makarov@auriga.com>
> ---
>   include/linux/pci_ids.h | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
> index e63c02a..3633cc6 100644
> --- a/include/linux/pci_ids.h
> +++ b/include/linux/pci_ids.h
> @@ -2327,6 +2327,8 @@
>   #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea
>   #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb
>
> +#define PCI_VENDOR_ID_CAVIUM		0x177d
> +
>   #define PCI_VENDOR_ID_BELKIN		0x1799
>   #define PCI_DEVICE_ID_BELKIN_F5D7010V7	0x701f
>
>
