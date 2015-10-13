From: Janusz Wolak <januszvdm@gmail.com>
Subject: Re: e1000_driver_checkpatch_remove_errors_warnings_checks
Date: Tue, 13 Oct 2015 23:39:17 +0200
Message-ID: <561D7A05.3070506@gmail.com>
References: <561AB462.5080701@gmail.com> <1444718258.2870.18.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34289 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110AbbJMVjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 17:39:20 -0400
Received: by lfaz124 with SMTP id z124so2804674lfa.1
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 14:39:19 -0700 (PDT)
In-Reply-To: <1444718258.2870.18.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had used checkpatch.pl as You suggested. I decided to leave gmail( 
januszvdm@gmail.com ) because I had had problems with git send-email (I 
guess that e-mail client caused the last problem). I've switched to 
januszwolak@awokados.com.pl


W dniu 13.10.2015 o 08:37, Jeff Kirsher pisze:
> On Sun, 2015-10-11 at 21:11 +0200, Janusz Wolak wrote:
>>   From daf0a1f5100c21f10b9e08829433258267748c44 Mon Sep 17 00:00:00
>> 2001
>> From: Janusz Wolak <januszvdm@gmail.com>
>> Date: Tue, 6 Oct 2015 21:03:19 +0200
>> Subject: [PATCH 1/6] Remove checkpatch warnings and checks.
>>
>> Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
>> ---
>>    drivers/net/ethernet/intel/e1000/e1000_main.c | 145
>> ++++++++++++++------------
>>    1 file changed, 76 insertions(+), 69 deletions(-)
>
> Your patch is not applicable, because you sent a corrupt patch.  Please
> use checkpatch.pl on your patches before sending them out for review.
>
