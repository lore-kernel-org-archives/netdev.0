From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH v2] net: add new QCA alx ethernet driver
Date: Thu, 23 Aug 2012 06:56:51 +0000
Message-ID: <157393863283F442885425D2C45428562A4F519A@nasanexd02f.na.qualcomm.com>
References: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
	<20120822.225700.714020017287504609.davem@davemloft.net>
	<157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
 <20120822.234019.1546353507351890178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ren, Cloud" <cjren@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120822.234019.1546353507351890178.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Then add a new ethtool operation to support your use case, that's exactly
> what I was telling you to do.
> 
> Did it really not occur to you that you perhaps you should extend existing
> generic facilities to suit your needs instead of creating private facilities that no
> other driver can use?

I'm afraid someone also rejects my request to add such operation to ethtool 
By your same reason.
before adding this interface, we had searched the kernel, marvell driver also 
Uses it, we had thought could be ok.

Of course, we will respect your opinion if it's not appropriated.

Thanks
Xiong
