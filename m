From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH net] net: tg3: fix NULL pointer dereference in
 tg3_io_error_detected and tg3_io_slot_reset
Date: Thu, 15 Aug 2013 10:32:58 -0700
Message-ID: <520D10CA.7040600@broadcom.com>
References: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
 <20130815.010726.719593168454341579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	shangw@linux.vnet.ibm.com, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3395 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757666Ab3HORdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 13:33:10 -0400
In-Reply-To: <20130815.010726.719593168454341579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Cc: Michael Chan <mchan@broadcom.com>
>> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
>
> Can I get some reviews from the Broadcom folks?
>

David,
I made the additional changes to Daniel's patch and Michael Chan reviewed it 
before I submitted.

Sorry, I forgot to add Michael's Signed-off-by. Do you want me to resend it with 
his Signed-off-by added?

Thanks,
Nithin.


> Thanks.
>
