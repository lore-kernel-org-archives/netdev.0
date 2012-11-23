From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Fri, 23 Nov 2012 22:02:09 +0100
Message-ID: <50AFE451.9010200@unimore.it>
References: <20121122165620.GA9714@paolo-ThinkPad-W520> <20121123.142817.1791723278472502940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from servizi.voixit.com ([78.46.247.94]:52012 "EHLO
	servizi.voixit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756176Ab2KWVCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 16:02:12 -0500
In-Reply-To: <20121123.142817.1791723278472502940.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 23/11/2012 20:28, David Miller ha scritto:
> From: Paolo Valente <paolo.valente@unimore.it>
> Date: Thu, 22 Nov 2012 17:56:20 +0100
>
>> +/*
>> +
>> + */
>
> Please don't add useless things like this in your patch.
>
Sorry, I forgot to remove it after I moved the body of the comment to a 
better place. I have fixed and checked again the patch.
> Thank you.
>


-- 
-----------------------------------------------------------
| Paolo Valente              |                            |
| Algogroup                  |                            |
| Dip. Ing. Informazione     | tel:   +39 059 2056318     |
| Via Vignolese 905/b        | fax:   +39 059 2056129     |
| 41125 Modena - Italy       |                            |
|     home:  http://algo.ing.unimo.it/people/paolo/       |
-----------------------------------------------------------
