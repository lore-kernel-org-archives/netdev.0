From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V3 PATCH 5/9] csiostor: Chelsio FCoE offload driver submission
 (sources part 5).
Date: Wed, 12 Sep 2012 11:10:53 +0530
Message-ID: <50502065.1090807@chelsio.com>
References: <1347374347-3852-1-git-send-email-naresh@chelsio.com> <1347374347-3852-6-git-send-email-naresh@chelsio.com> <20120911.133510.1351483747174862495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120911.133510.1351483747174862495.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/11/2012 11:05 PM, David Miller wrote:
> From: Naresh Kumar Inna <naresh@chelsio.com>
> Date: Tue, 11 Sep 2012 20:09:03 +0530
> 
>> +#include <linux/moduleparam.h>
> 
> This header include is not necessary.
> 

I will remove it, thanks.
