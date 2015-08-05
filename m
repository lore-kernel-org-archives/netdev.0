From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: [PATCH v2] e1000e: Modify tx/rx configurations to avoid null
 pointer dereferences in e1000_open
Date: Wed, 05 Aug 2015 20:34:24 +0800
Message-ID: <55C202D0.3050003@163.com>
References: <1438769770-8887-1-git-send-email-baijiaju1990@163.com> <1438771429.3467.28.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, alexander.duyck@gmail.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:53383 "EHLO m50-134.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbbHEMeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 08:34:46 -0400
In-Reply-To: <1438771429.3467.28.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2015 06:43 PM, Jeff Kirsher wrote:
>
> Is your intention that this patch replace the existing patch:
> http://patchwork.ozlabs.org/patch/502990/
> ...which is currently in my queue?
>

Okay, please replace the previous patch.
