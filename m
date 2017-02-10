From: Yanjun Zhu <yanjun.zhu@oracle.com>
Subject: Re: [PATCH 1/1] ixgbe: add the external ixgbe fiber transceiver
 status
Date: Fri, 10 Feb 2017 10:43:59 +0800
Message-ID: <589D28EF.1050602@oracle.com>
References: <1486609408-6770-1-git-send-email-yanjun.zhu@oracle.com>
 <87618083B2453E4A8714035B62D679925074E73F@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "broonie@kernel.org" <broonie@kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:26355 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdBJCpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 21:45:17 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1A2il90030400
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 02:44:47 GMT
In-Reply-To: <87618083B2453E4A8714035B62D679925074E73F@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/2/10 3:08, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of Zhu Yanjun
>> Sent: Wednesday, February 08, 2017 7:03 PM
>> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; broonie@kernel.org;
>> davem@davemloft.net; intel-wired-lan@lists.osuosl.org;
>> netdev@vger.kernel.org
>> Subject: [PATCH 1/1] ixgbe: add the external ixgbe fiber transceiver status
>>
>> When the ixgbe fiber transceiver is external, it is necessary to get
>> the present/absent status of this external ixgbe fiber transceiver.
> The transceiver field was deprecated in the old ethtool API and is being
> removed in the new. This patch will not apply at all once those changes are made:
>
> http://patchwork.ozlabs.org/patch/725081/
Thanks for your kind reply. I will change this patch based on the above 
changes.

Zhu Yanjun
>
> Thanks,
> Emil
>   
>
>
