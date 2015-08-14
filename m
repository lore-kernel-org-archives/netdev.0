From: Philip Downey <pdowney@Brocade.com>
Subject: RE: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Fri, 14 Aug 2015 14:36:06 +0000
Message-ID: <a5b8619ebf394a1db5743ca2da45ad0d@EMEAWP-EXMB12.corp.brocade.com>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
 <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
 <20150813160626.GF32484@lunn.ch>
 <b50a97f544f5437fb18df1cb5b6b6533@EMEAWP-EXMB12.corp.brocade.com>
 <20150813170137.GE32627@lunn.ch>
 <b74d1e7c6693479bb9caf0c3fef5d7a2@EMEAWP-EXMB12.corp.brocade.com>
 <20150814133512.GL32627@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150814133512.GL32627@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew
Will resubmit with the information you suggest.
There might be a slight delay for this as I am on holiday now for a week.

Rest regards

Philip

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, August 14, 2015 2:35 PM
> To: Philip Downey
> Cc: David Miller; kuznet@ms2.inr.ac.ru; jmorris@namei.org; yoshfuji@linux-
> ipv6.org; kaber@trash.net; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
> 
> Hi Philip
> 
> So with a bit of poking and prodding, we have a much better understanding
> as to why this is O.K. Maybe your next patch can quote the relevant RFCs
> and have a much fuller commit message?
> 
> Thanks
> 	Andrew
