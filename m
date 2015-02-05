From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3 0/2] iproute2: bridge vlan range support
Date: Thu, 5 Feb 2015 10:48:09 -0800
Message-ID: <20150205104809.603763cf@urahara>
References: <1422239185-14054-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	wkok@cumulusnetworks.com, sfeldma@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:46845 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbBESsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:48:11 -0500
Received: by pdjz10 with SMTP id z10so9366113pdj.13
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:48:10 -0800 (PST)
In-Reply-To: <1422239185-14054-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Jan 2015 18:26:23 -0800
roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This series adds support for vlan ranges in iproute2 bridge add
> and show commands.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> 
> Roopa Prabhu (2):
>   iproute2: bridge: support vlan range for adds
>   iproute2: bridge vlan show new option to print ranges
> 
>  bridge/br_common.h        |    1 +
>  bridge/bridge.c           |    6 ++++-
>  bridge/vlan.c             |   55 ++++++++++++++++++++++++++++++++++++++++-----
>  include/linux/if_bridge.h |    2 ++
>  include/linux/rtnetlink.h |    1 +
>  5 files changed, 58 insertions(+), 7 deletions(-)
> 

Applied to net-next branch of iproute2
Go ahead and send more patches if you decide on different output format.
