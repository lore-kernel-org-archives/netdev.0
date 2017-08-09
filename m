From: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibmvnic: Fix unused variable warning
Date: Wed, 9 Aug 2017 10:03:42 -0700
Message-ID: <7872eab5-9af4-a622-990c-59bf92834c05@linux.vnet.ibm.com>
References: <20170809111602.12170-1-msuchanek@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Michal Suchanek <msuchanek@suse.de>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:44365 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754198AbdHIRDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 13:03:52 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v79H3gvH122007
        for <netdev@vger.kernel.org>; Wed, 9 Aug 2017 13:03:52 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c85ybhwy0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 13:03:52 -0400
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tyreld@linux.vnet.ibm.com>;
        Wed, 9 Aug 2017 11:03:49 -0600
In-Reply-To: <20170809111602.12170-1-msuchanek@suse.de>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2017 04:16 AM, Michal Suchanek wrote:
> Fixes: a248878d7a1d ("ibmvnic: Check for transport event on driver resume")
> 
> Signed-off-by: Michal Suchanek <msuchanek@suse.de>
> ---

Reviewed-by: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>
