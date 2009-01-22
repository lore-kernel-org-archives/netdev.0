From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 1/9] bnx2x: remove a few trivial macros
Date: Thu, 22 Jan 2009 19:49:06 +0200
Message-ID: <1232646546.29087.84.camel@lb-tlvb-eliezer>
References: <1232517046.9701.19.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2490 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758953AbZAVRuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 12:50:20 -0500
In-Reply-To: <1232517046.9701.19.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Eilon, after this series, sparse with endian-checking at least gets through a
> compile without hitting too many errors, patch 9 is a functional change
> and may have exposed an endian bug in the driver....but I had to get through
> the other 8 to see it ;-)
> 
> patches 1-8 shouldn't change any behavior...if it does it wasn't intentional.
> 
>  drivers/net/bnx2x.h      |    4 ---
>  drivers/net/bnx2x_main.c |   62 +++++++++++++++++++++++-----------------------
>  2 files changed, 31 insertions(+), 35 deletions(-)

Thanks Harvey! This change looks good

Acked-by: Eilon Greenstein <eilong@broadcom.com>


