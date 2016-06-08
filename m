From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] ipaddress: Allow listing addresses by type
Date: Wed, 8 Jun 2016 08:35:54 -0700
Message-ID: <20160608083554.639d1286@xeon-e3>
References: <ba62a9b5ffab44adaf0532dc4ca6725d@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vadim Kochan <vadim4j@gmail.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:25246 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422920AbcFHPfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:35:46 -0400
In-Reply-To: <ba62a9b5ffab44adaf0532dc4ca6725d@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jun 2016 19:57:27 +0000
Phil Sutter <phil@nwl.cc> wrote:

> Not sure why this was limited to ip-link before. It is semantically
> equal to the 'master' keyword, which is not restricted at all.
> 
> Cc: Vadim Kochan <vadim4j@gmail.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Please resubmit and update usage and man page.
