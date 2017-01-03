From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v2 0/6] i40e: Add VF Port
 representator support for SR-IOV VFs
Date: Tue, 3 Jan 2017 12:04:17 -0800
Message-ID: <CAKgT0UeKO+2jfnPQwGE6DbzxgLCLGPt+6WxduGhBXgBZz_14eQ@mail.gmail.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com> <CAJ3xEMhcVnGH52rkyYbDOox89=+DNShDcPS-wr2a8VAgBZYMWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        jakub.kicinski@netronome.com,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34462 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752574AbdACUES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 15:04:18 -0500
Received: by mail-io0-f193.google.com with SMTP id n85so31467420ioi.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 12:04:18 -0800 (PST)
In-Reply-To: <CAJ3xEMhcVnGH52rkyYbDOox89=+DNShDcPS-wr2a8VAgBZYMWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2017 at 11:48 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Jan 3, 2017 at 8:07 PM, Sridhar Samudrala
> <sridhar.samudrala@intel.com> wrote:
>> - Patch 4 adds a new type to metadata_dst to allow passing VF id to lower device.
>
> again... I didn't get this one on my subscription, nor I see it in the archives

It looks like netdev was on the list of email addresses for that
patch.  It might just be that the mail server has delayed it.

If you want you can pull it out of the Intel Wired Lan patchwork at
http://patchwork.ozlabs.org/project/intel-wired-lan/list/

- Alex
