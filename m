From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] genetlink: remove ops_list from genetlink
 header.
Date: Sun, 4 Jun 2017 20:18:22 +0300
Message-ID: <b68021eb-180c-f486-3e0e-546824444b5b@cogentembedded.com>
References: <1496560061-1673-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: Rami Rosen <rami.rosen@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36436 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdFDRSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 13:18:23 -0400
Received: by mail-lf0-f44.google.com with SMTP id o83so13684628lff.3
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 10:18:22 -0700 (PDT)
In-Reply-To: <1496560061-1673-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 6/4/2017 10:07 AM, Rami Rosen wrote:

> commit d91824 ("genetlink: register family ops as array") removed the

    At least 12 digits required.

> ops_list member from both genl_family and genl_ops; while the
> documentation of genl_family was updated accordingly by this patch,
> ops_list remained in the documentation of the genl_ops object.
> This patch fixes it by removing ops_list from genl_ops documentation.
>
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>
[...]

MNR, Sergei
