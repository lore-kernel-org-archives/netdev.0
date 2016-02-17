From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 6/8] net: ixgbe: add minimal parser details
 for ixgbe
Date: Wed, 17 Feb 2016 14:34:12 -0800
Message-ID: <56C4F564.7040000@gmail.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810> <20160217051828.17139.51653.stgit@john-Precision-Tower-5810> <80F0E864-49F7-4182-8CE5-C814C1A4DD43@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, "amir@vadai.me" <amir@vadai.me>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33450 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423779AbcBQWe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 17:34:26 -0500
Received: by mail-pf0-f169.google.com with SMTP id q63so18907949pfb.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 14:34:25 -0800 (PST)
In-Reply-To: <80F0E864-49F7-4182-8CE5-C814C1A4DD43@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 10:01 AM, Rustad, Mark D wrote:
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
>> new file mode 100644
>> index 0000000..43ebec4
>> --- /dev/null
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
>> @@ -0,0 +1,112 @@
>> +/*******************************************************************************
>>
>> + *
>> + * Intel 10 Gigabit PCI Express Linux drive
>> + * Copyright(c) 2013 - 2015 Intel Corporation.
> 
> Those copyright dates don't seem reasonable for a new file, since it
> clearly didn't exist in 2013. IANAL, but it has to be better to at least
> be accurate about when it was created.
> 
> -- 
> Mark Rustad, Networking Division, Intel Corporation

Sure I'll fix this as well. :/ thanks Mark.
