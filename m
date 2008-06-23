From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [RESEND PATCH 1/3] e1000e: set CONFIG_E1000E=y in x86 defconfigs
Date: Mon, 23 Jun 2008 16:14:39 -0700
Message-ID: <9929d2390806231614j66b51d01v103b7dc4efd81b38@mail.gmail.com>
References: <20080622221916.5907.79563.stgit@localhost.localdomain>
	 <20080623112618.GC7485@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:44687 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbYFWXOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 19:14:40 -0400
Received: by py-out-1112.google.com with SMTP id p76so1153495pyb.10
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 16:14:39 -0700 (PDT)
In-Reply-To: <20080623112618.GC7485@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 4:26 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>
>> From: Auke Kok <auke-jan.h.kok@intel.com>
>>
>> This adds to the already default CONFIG_E1000=y in these files.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>>  arch/x86/configs/i386_defconfig   |    1 +
>>  arch/x86/configs/x86_64_defconfig |    1 +
>
> that is not an e1000 patch but an arch/x86 defconfig patch. NAK on this
> route of patch propagation.
>

So you are fine with the patch contents, just not the title/subject
line.  So if the subject line was:

[RESEND PATCH 1/3] x86 defconfig: set CONFIG_E1000E=y in x86 defconfigs

Would that have been alright?

-- 
Cheers,
Jeff
