From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 5/6] stmmac: configure burst related GMAC DMA parameters
Date: Wed, 7 Mar 2012 11:09:37 +0530
Message-ID: <4F56F499.9040403@st.com>
References: <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <1330692928-30330-5-git-send-email-deepak.sikri@st.com> <1330692928-30330-6-git-send-email-deepak.sikri@st.com> <20120304.205212.433059905942216884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>,
	spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Vikas MANOCHA <vikas.manocha@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:41081 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699Ab2CGFkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 00:40:17 -0500
In-Reply-To: <20120304.205212.433059905942216884.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 3/5/2012 7:22 AM, David Miller wrote:
> From: Deepak Sikri<deepak.sikri@st.com>
> Date: Fri, 2 Mar 2012 18:25:27 +0530
>
>>   	writel(value, ioaddr + DMA_BUS_MODE);
>> +	/*
>> +	 * We need to program DMA_AXI_BUS_MODE for supported bursts in
>> +	 * case DMA_BUS_MODE_FB mode is selected
> Please fix comment formatting.
>
This would be fixed.

Thanks
Deepak
