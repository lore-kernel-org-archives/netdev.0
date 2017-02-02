From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH net-next] net: add LINUX_MIB_PFMEMALLOCDROP counter
Date: Thu, 2 Feb 2017 09:48:50 -0500
Message-ID: <1486046930.29885.20.camel@fb.com>
References: <1486010879.13103.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37921 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751045AbdBBOtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 09:49:11 -0500
In-Reply-To: <1486010879.13103.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 20:47 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Debugging issues caused by pfmemalloc is often tedious.
> 
> Add a new SNMP counter to more easily diagnose these problems.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Josef Bacik <jbacik@fb.com>

Acked-by: Josef Bacik <jbacik@fb.com>

Thanks Eric,

Josef
