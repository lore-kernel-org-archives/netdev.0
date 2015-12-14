From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: Re: [PATCH v4 1/5] geneve: Add geneve udp port offload for ethernet
 devices
Date: Mon, 14 Dec 2015 11:48:39 -0800
Message-ID: <566F1D17.3010008@intel.com>
References: <1450123080-206406-1-git-send-email-anjali.singhai@intel.com>
 <1450123080-206406-2-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63727 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752837AbbLNTsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 14:48:41 -0500
In-Reply-To: <1450123080-206406-2-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending the series with a  cover-letter that got missed.

Thanks
Anjali

On 12/14/2015 11:57 AM, Anjali Singhai Jain wrote:
> Add ndo_ops to add/del UDP ports to a device that supports geneve
> offload.
>
> v2: Comment fix.
>
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> ---
>   drivers/net/geneve.c      | 23 +++++++++++++++++++++++
>   include/linux/netdevice.h | 20 +++++++++++++++++++-
>   2 files changed, 42 insertions(+), 1 deletion(-)
>
>
