From: Jing Huang <huangj@Brocade.COM>
Subject: RE: [net-next 00/12] bna: Update bna driver version to 3.0.2.1
Date: Wed, 7 Sep 2011 12:24:03 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A9E817C100@HQ1-EXCH01.corp.brocade.com>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Ivan Vecera <ivecera@redhat.com>
To: Rasesh Mody <rmody@brocade.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:48135 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750731Ab1IGTjv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 15:39:51 -0400
In-Reply-To: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>   This series is re-submitted with the comments addressed:
>   BNAD_PCI_UNMAP_SKB and BNAD_DIM_TIMER_STOP macros have been
>dropped
>   and added bnad_pci_unmap_skb API.
>   We are not adding new prefetch which we might selectively add later
>   for performance improvement.
>   This also addresses earlier comments.
>
>   The following patch set contains TX and RX path changes and Ethtool
>   enhancements. This also fixes bugs found with v3.0.2.0 code. It cleans
>   up unused code, naming changes, formatting changes and comments
>   addition/deletion.
>
>   This updates the Brocade BNA driver to v3.0.2.1.
>
>   The driver has been compiled & tested against net-next-2.6(3.0.0-rc7)
>
>Thanks,
>Rasesh
>

Hi Dave,

Are you going to approve this patch set? Patchwork shows that It is still
in under review and I am wondering if this is due to network git freeze.

Thanks
Jing
