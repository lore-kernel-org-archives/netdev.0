From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 3/6] [net-next]net: i40e: Extend set switch config command
 to accept cloud filter mode
Date: Tue, 1 Aug 2017 06:48:26 -0400
Message-ID: <5dd27049-2283-4563-1d83-1c42fdd2f5e9@mojatatu.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154786980.4135.7459136530514071209.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34204 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdHAKsd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:48:33 -0400
Received: by mail-it0-f67.google.com with SMTP id t78so1325735ita.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 03:48:33 -0700 (PDT)
In-Reply-To: <150154786980.4135.7459136530514071209.stgit@anamdev.jf.intel.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 08:37 PM, Amritha Nambiar wrote:
> Add definitions for L4 filters and switch modes based on cloud filters
> modes and extend the set switch config command to include the
> additional cloud filter mode.
> 

"Cloud filters"? Seriously? Is "enteprise" the next one? ;->

cheers,
jamal
