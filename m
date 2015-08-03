From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] mpls: Use definition for reserved label checks
Date: Mon, 03 Aug 2015 14:45:19 -0700
Message-ID: <55BFE0EF.5010000@cumulusnetworks.com>
References: <1438620604-18746-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33368 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337AbbHCVpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:45:21 -0400
Received: by padck2 with SMTP id ck2so99012491pad.0
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 14:45:21 -0700 (PDT)
In-Reply-To: <1438620604-18746-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/15, 9:50 AM, Robert Shearman wrote:
> In multiple locations there are checks for whether the label in hand
> is a reserved label or not using the arbritray value of 16. Factor
> this out into a #define for better maintainability and for
> documentation.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
