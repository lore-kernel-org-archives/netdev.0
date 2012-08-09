From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] net: add new QCA alx ethernet driver
Date: Wed, 08 Aug 2012 21:09:42 -0700
Message-ID: <1344485382.2024.9.camel@joe2Laptop>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	 <6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"Hao-Ran Liu(Joseph Liu)" <hao-ran.liu@canonical.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-09 at 02:27 +0000, Ren, Cloud wrote:
> Hi David,
[]
> The alx driver only supports two new nics(l1f/l2f) now.  It doesn't s=
upersede atl1c driver.
> Atl1c driver still supports old nics.
[]
> -----Original Message-----
> From: Ren, Cloud=20
> Sent: 2012=E5=B9=B48=E6=9C=889=E6=97=A5 18:15
[]
> This driver support two new ethernet chipsets:

[+400kb of entire original patch]

Did you really have to quote 400kb of original patch to
make that prefixing statement to David?

[]

> Signed-off-by: Joe Perches <joe@perches.com>
=20
I would prefer my name not be listed as a Signed-off-by.

I don't have a card, I never tested it, etc.  What I did
do is a light review and made a couple of trivial patch
suggestions about how you might make logging code a bit
smaller.

Thanks and cheers, Joe
