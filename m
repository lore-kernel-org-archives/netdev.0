From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH RFC] xen-netback: calculate the number of
 slots required for large MTU vifs
Date: Tue, 16 Jul 2013 18:08:03 +0800
Message-ID: <51E51B83.7040302@oracle.com>
References: <20130709221406.GA13671@u109add4315675089e695.ant.amazon.com> <1373409659-22383-1-git-send-email-msw@amazon.com> <20130710081333.GI19798@zion.uk.xensource.com> <20130710193703.GB20453@zion.uk.xensource.com> <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	Xi Xiong <xixiong@amazon.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	xen-devel@lists.xenproject.org
To: Matt Wilson <msw@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17793 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101Ab3GPKGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 06:06:53 -0400
In-Reply-To: <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-7-11 13:14, Matt Wilson wrote:
> I think that this patch addresses the problem more completely. Annie?

Agree, it is better to take your patch. Would you like to go forward 
with it? This issue is obvious and easy to be hit with larger MTU size.

Thanks
Annie
