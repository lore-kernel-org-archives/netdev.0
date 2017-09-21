From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH] tc/mirred: Clean up white-space noise
Date: Wed, 20 Sep 2017 17:59:12 -0700
Message-ID: <20170920175912.31dfe0a7@xeon-e3>
References: <150529711361.57333.10151730051655064515.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:45406 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdIUA7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:59:15 -0400
Received: by mail-pf0-f182.google.com with SMTP id z84so2400415pfi.2
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 17:59:15 -0700 (PDT)
In-Reply-To: <150529711361.57333.10151730051655064515.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Sep 2017 03:05:13 -0700
Amritha Nambiar <amritha.nambiar@intel.com> wrote:

> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> ---
>  include/linux/tc_act/tc_mirred.h |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/tc_act/tc_mirred.h b/include/linux/tc_act/tc_mirred.h
> index 3d7a2b3..69038c2 100644
> --- a/include/linux/tc_act/tc_mirred.h
> +++ b/include/linux/tc_act/tc_mirred.h

All files in include/linux are perodically refreshed from the uapi directory
in the kernel source.

Please re-submit this as a patch to net-next in kernel against include/uapi/tc_act/tc_mirred.h
and then iproute2 will pick it up in next pass.
