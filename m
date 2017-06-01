From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net] ibmvnic: Update module author
Date: Thu, 1 Jun 2017 10:53:13 -0500
Message-ID: <ca0058c6-ef92-da31-a4e9-50d4e930ed72@linux.vnet.ibm.com>
References: <1496262931-15978-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20170531.171203.1567468797463479514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57635 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751149AbdFAPxR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:53:17 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51Fn9t3031706
        for <netdev@vger.kernel.org>; Thu, 1 Jun 2017 11:53:16 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2atntsgbb5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 11:53:16 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 1 Jun 2017 11:53:15 -0400
In-Reply-To: <20170531.171203.1567468797463479514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2017 04:12 PM, David Miller wrote:
> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Date: Wed, 31 May 2017 15:35:31 -0500
>
>> Update the module author to be one of the original co-maintainers
>> of the driver. The original author left the project long ago and
>> so far has not responded to emails sent to the listed address.
>>
>> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
>> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> It's MODULE_AUTHOR not MODULE_MAINTAINER.
>
Would it be better to include a second or more authors and/or remove the original author's mailing address, which isn't valid anymore?  How should this be handled?
