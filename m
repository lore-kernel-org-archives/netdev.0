From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] net: mpls: Update lfib_nlmsg_size to skip
 deleted nexthops
Date: Wed, 29 Mar 2017 11:20:09 +0100
Message-ID: <f2b5869d-0010-3d50-276b-4542fb3ba183@brocade.com>
References: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60605 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755116AbdC2KUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 06:20:21 -0400
In-Reply-To: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/03/17 23:19, David Ahern wrote:
> A recent commit skips nexthops in a route if the device has been
> deleted. Update lfib_nlmsg_size accordingly.
>
> Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Robert Shearman <rshearma@brocade.com>
