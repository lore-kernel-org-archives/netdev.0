From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: [PATCH] bna: use device model DMA API
Date: Wed, 2 Feb 2011 15:04:19 -0800
Message-ID: <B11AB91666F22D498EEC66410EB3D3C4F416989B9F@HQ1-EXCH01.corp.brocade.com>
References: <1296657422-13537-1-git-send-email-ivecera@redhat.com>
 <20110202.150308.246520172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rasesh Mody <rmody@brocade.com>
To: David Miller <davem@davemloft.net>,
	"ivecera@redhat.com" <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:44296 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755268Ab1BBX3h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 18:29:37 -0500
In-Reply-To: <20110202.150308.246520172.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, February 02, 2011 3:03 PM
To: ivecera@redhat.com
Cc: netdev@vger.kernel.org; Rasesh Mody; Debashis Dutt
Subject: Re: [PATCH] bna: use device model DMA API

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  2 Feb 2011 15:37:02 +0100

> Use DMA API as PCI equivalents will be deprecated.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Looks good to me, can we get some review from the BNA maintainers
please?

Ivan, David, 

I just finished reviewing the patches. Looks good to me too.

Thanks
--Debashis
