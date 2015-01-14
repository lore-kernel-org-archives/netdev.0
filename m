From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: Re: [PATCH v2 1/1] atm: remove deprecated use of pci api
Date: Wed, 14 Jan 2015 15:25:05 +0100
Message-ID: <54B67C41.3080400@gmail.com>
References: <20150112161042.GA11374@sloth>	<20150113.215944.1703977685948196746.davem@davemloft.net> <20150114085851.234db50d@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150114085851.234db50d@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 14/01/2015 14:58, chas williams - CONTRACTOR wrote:
> I think I would like to go through and just fix all the usages of the
> older pci interface.  This patch isn't very complete due to its
> automated nature.
>
> I will make some time this weekend.
It was my original intent to produce a complete patch, I obviously
misused the tool and forgot a significant number of cases.

But I am ok with fixing that and submitting a complete version of this
patch if you like.
