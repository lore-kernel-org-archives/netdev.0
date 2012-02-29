From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Wed, 29 Feb 2012 01:38:03 -0800
Message-ID: <CAB=NE6Us9THvXDLvkxiuridOD1ry60pLyzQsWBronBHCUNV3Vg@mail.gmail.com>
References: <157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
 <20120228.212857.797446903975232476.davem@davemloft.net> <157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com>
 <20120228.223258.2261979237568571219.davem@davemloft.net> <157393863283F442885425D2C454285619415703@nasanexd02a.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Giori, Kathy" <kgiori@qca.qualcomm.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <157393863283F442885425D2C454285619415703@nasanexd02a.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 11:30 PM, Huang, Xiong <xiong@qca.qualcomm.com> wrote:
> My another concern is the license type. Current atl1c use GPL v2, and got some contribution outside of QCA though the first version
> was wrote by our Atheros guy. And that guy just copied the license from atl1e/atl1x that contains the words "Derived from Intel e1000".
>
> If I update this driver and add new chip support on it, Our Company's legal might not permit me to do so, they prefer QCA ISC license.
> Is it possible to change the license header to ISC while I applying patches to source code ?

No.

  Luis
