From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: UDP and Raw packet output not scaling with number of cores
 (10G, ixgbe and bnx2x)
Date: Sun, 14 Sep 2008 13:06:07 +0300
Message-ID: <1221386767.15079.8.camel@lb-tlvb-eliezer>
References: <C499405203244F4F8ECC637C6A8F498B07D8E9ED@sd-exchange>
 <20080911.203450.29338239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "wurzel@ccpu.com" <wurzel@ccpu.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20080911.203450.29338239.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2008-09-11 at 20:34 -0700, David Miller wrote:
> From: "wurzel parsons-keir" <wurzel@ccpu.com>
> Date: Thu, 11 Sep 2008 20:21:36 -0700
> 
> > I read posts from Dave Miller from July 3 about making the tx path
> > multiqueue aware, and also a paper by Zhu Yi and another by Redhat
> > on how all this should make the TX path totally parallel/scalable
> > across my 8 cores, if I understand correctly.
> >
Hi,

The bnx2x still does not support the Tx multiqueue. A patch is planned
in the near future for it.

Regards,
Eilon


