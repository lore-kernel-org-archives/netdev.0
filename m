From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5 net-next] ibmvnic: Activate disabled RX buffer pools
 on reset
Date: Wed, 14 Jun 2017 22:47:52 -0500
Message-ID: <819b480e-da56-e989-9691-0a3eac6805b4@linux.vnet.ibm.com>
References: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20170614.234204.669779876622082650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59190 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750768AbdFODsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 23:48:03 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F3hoCJ041162
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:48:02 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b3je68f0w-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:48:02 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 14 Jun 2017 23:48:01 -0400
In-Reply-To: <20170614.234204.669779876622082650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 10:42 PM, David Miller wrote:
> Please always provide a proper "[PATCH 0/N ...] " header posting
> explaining what the patch series is doing, how it is doing it, and why
> it is doing it that way.
>
> I am getting kind of tired asking people for this FWIW...
>
Sorry, I will send a v2 with a proper header patch shortly.  Thanks for the prompt feedback.
