From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: linux-next network throughput performance regression
Date: Fri, 6 Nov 2015 14:30:08 -0700
Message-ID: <563D1BE0.2070107@cumulusnetworks.com>
References: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1180.60206@cumulusnetworks.com>
 <CY1PR03MB13763CB0C0A9C822660E248AC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Simon Xiao <sixiao@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34761 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966140AbbKFVaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 16:30:11 -0500
Received: by iody8 with SMTP id y8so135126296iod.1
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 13:30:10 -0800 (PST)
In-Reply-To: <CY1PR03MB13763CB0C0A9C822660E248AC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/6/15 2:18 PM, Simon Xiao wrote:
> The .config file used to build linux-next kernel is attached to this mail.

Thanks.

Failed to notice this on the first response; my brain filled in. Why 
linux-next tree? Can you try net-next which is more relevant for this 
mailing list, post the top commit id and config file used?
