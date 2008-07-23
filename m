From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET-NEXT PATCH 1/9] e1000: neaten function declarations
Date: Wed, 23 Jul 2008 09:13:37 -0700
Message-ID: <9929d2390807230913v13c3f317n44e8313cfad45874@mail.gmail.com>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
	 <20080711221702.3255.43654.stgit@localhost.localdomain>
	 <48866FD4.2010706@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Joe Perches" <joe@perches.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:25342 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbYGWQNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 12:13:38 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1446976waf.23
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 09:13:38 -0700 (PDT)
In-Reply-To: <48866FD4.2010706@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 4:40 PM, Jeff Garzik <jeff@garzik.org> wrote:
> Jeff Kirsher wrote:
>>
>> From: Joe Perches <joe@perches.com>
>>
>> Signed-off-by: Joe Perches <joe@perches.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000_ethtool.c |  175 +++++-------
>>  drivers/net/e1000/e1000_hw.c      |  558
>> +++++++++++++------------------------
>>  drivers/net/e1000/e1000_main.c    |  307 ++++++++------------
>>  drivers/net/e1000/e1000_param.c   |   16 -
>>  4 files changed, 385 insertions(+), 671 deletions(-)
>
> applied 1-9, after making the obvious fixes to the er32/ew32 patch
>

Thanks.

-- 
Cheers,
Jeff
