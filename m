From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Tue, 10 Dec 2013 10:40:32 -0800
Message-ID: <1386700832.1752.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1386614601-9453-1-git-send-email-natg@google.com>
	 <1386615608.1752.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGmqidkxoi9EEe0uC18QQUXwjFP1e_1MXL7VPk+NtU-Ta6FGUg@mail.gmail.com>
	 <52A633B4.9000307@cogentembedded.com>
	 <1386623253.1752.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1386658724.1752.19.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGmqidnusPSYt9GHfQVs7SP620jyEN=Aicr1jS3Esb9C5Ov2wA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<nsujir@broadcom.com>, <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Natarajan Gurumoorthy <natg@google.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGmqidnusPSYt9GHfQVs7SP620jyEN=Aicr1jS3Esb9C5Ov2wA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-10 at 07:01 -0800, Natarajan Gurumoorthy wrote:
>      The only time I see crashes is after the tg3 driver has been
> loaded into the system. I our use case we are poking around
> /sys/devices/pcixxxx/......../config. 

David, please apply this first patch.

Acked-by: Michael Chan <mchan@broadcom.com>
