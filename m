From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Fwd: Re: [PATCH v2 net-next 0/3] net sched action timestamp
 improvements
Date: Fri, 17 Jun 2016 07:15:27 -0400
Message-ID: <5763DBCF.9080203@mojatatu.com>
References: <20160607.155405.778592531194331404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33998 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbcFQLP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 07:15:29 -0400
Received: by mail-io0-f181.google.com with SMTP id 5so74762964ioy.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 04:15:29 -0700 (PDT)
In-Reply-To: <20160607.155405.778592531194331404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, mystery solved. Dave, this patch series is missing from current
net-next.

cheers,
jamal
-------- Forwarded Message --------
Subject: Re: [PATCH v2 net-next 0/3] net sched action timestamp improvements
Date: Tue, 07 Jun 2016 15:54:05 -0700 (PDT)
From: David Miller <davem@davemloft.net>
To: jhs@mojatatu.com
CC: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, daniel@iogearbox.net

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon,  6 Jun 2016 06:32:52 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Various aggregations of duplicated code, fixes and introduction of firstused
> timestamp
>
> v2: add const for source time info per suggestion from Cong

Series applied.
