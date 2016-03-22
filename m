From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 1/3] net: add the AF_KCM entries to family name
 tables
Date: Tue, 22 Mar 2016 01:39:26 +0000
Message-ID: <BLUPR03MB1410742BFEB22EA3EE2E013EBF800@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1458553869-26756-1-git-send-email-decui@microsoft.com>
 <20160321.112742.1737417108964275737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0130.outbound.protection.outlook.com ([65.55.169.130]:40378
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758147AbcCVBj3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 21:39:29 -0400
In-Reply-To: <20160321.112742.1737417108964275737.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, March 21, 2016 23:28
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; KY Srinivasan
> <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> vkuznets@redhat.com
> Subject: Re: [PATCH net-next 1/3] net: add the AF_KCM entries to family
> name tables
> 
> 
> Two things wrong with this submission:
> 
> 1) You need to provide an initial "[PATCH net-next 0/3] ..." header posting
>    explaining at a high level what this patch series is about and how it is
>    implemented and why.

Hi David,
Thanks for the reply! I'll fix this.

> 2) The net-next tree is closed at this time because we are in the merge
> window,
>    therefore no new feature patches should be submitted to the netdev
> mailing
>    list at this time.  Please wait until some (reasonable) amount of time after
>    the merge window closes to resubmit this.

OK.  I'll repost it when the merge window is open -- I suppose that would happen
in 1~2 weeks, according to my reading the documentation.

Thanks,
-- Dexuan
