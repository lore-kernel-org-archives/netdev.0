From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add support for filtering neigh dump
 by master device
Date: Tue, 29 Sep 2015 21:28:34 -0700
Message-ID: <560B64F2.9000101@cumulusnetworks.com>
References: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34209 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbI3E2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:28:37 -0400
Received: by padhy16 with SMTP id hy16so27082943pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 21:28:36 -0700 (PDT)
In-Reply-To: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/15, 9:32 AM, David Ahern wrote:
> Add support for filtering neighbor dumps by master device by adding
> the NDA_MASTER attribute to the dump request. A new netlink flag,
> NLM_F_DUMP_FILTERED, is added to indicate the kernel supports the
> request and output is filtered as requested.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
