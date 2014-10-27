From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/5] stmmac: pci: use managed resources
Date: Mon, 27 Oct 2014 16:28:06 +0100
Message-ID: <544E6486.6040502@st.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>	 <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>	 <5446C827.2040801@cogentembedded.com> <1413966993.2396.26.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:53175 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750824AbaJ0P20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 11:28:26 -0400
In-Reply-To: <1413966993.2396.26.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 10:36 AM, Andy Shevchenko wrote:
> So, I was trying to find any specification on public regarding to boards
> that have this IP, no luck so far. I guess that that code was created
> due to XILINX FPGA usage which probably can provide any BAR user wants
> to. Thus, I imply that in real applications the BAR most probably will
> be 0. However, I left variable which can be overridden in future
> (regarding to PCI ID).
>
> It would be nice to hear someone from ST about this. Giuseppe?

Hello Andy

this chip is on ST SoCs since long time but embedded. I have no PCI
card. Added Rayagond on copy too

peppe
