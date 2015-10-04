From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add support for filtering neigh dump by
 device index
Date: Sun, 4 Oct 2015 16:31:07 +0200
Message-ID: <5611382B.9060004@cumulusnetworks.com>
References: <1443897826-30209-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33983 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbbJDObK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 10:31:10 -0400
Received: by wicfx3 with SMTP id fx3so87528405wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 07:31:09 -0700 (PDT)
In-Reply-To: <1443897826-30209-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2015 08:43 PM, David Ahern wrote:
> Add support for filtering neighbor dumps by device by adding the
> NDA_IFINDEX attribute to the dump request.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - fix or on the index as noticed by Eagle-Eye Nikolay
> 
>  net/core/neighbour.c | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
LGTM,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
