From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] mpls: support for dead routes
Date: Tue, 03 Nov 2015 08:00:10 -0800
Message-ID: <5638DA0A.3040806@cumulusnetworks.com>
References: <1446527581-64787-1-git-send-email-roopa@cumulusnetworks.com> <20151103.102802.1746914891520356480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33813 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438AbbKCQAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:00:13 -0500
Received: by padhx2 with SMTP id hx2so14182364pad.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 08:00:13 -0800 (PST)
In-Reply-To: <20151103.102802.1746914891520356480.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/15, 7:28 AM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Mon,  2 Nov 2015 21:13:01 -0800
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
>> routes due to link events. Also adds code to ignore dead
>> routes during route selection
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Robert found more issues, I think this is going to have to wait until the
> next merge window Roopa...
sure, that works. Thanks!.
