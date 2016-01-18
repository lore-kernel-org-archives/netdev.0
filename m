From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2 2/2] ip-link: fix man page warnings
Date: Mon, 18 Jan 2016 11:45:34 -0800
Message-ID: <20160118114534.05fb15ed@xeon-e3>
References: <1452791420-10771-1-git-send-email-nicolas.dichtel@6wind.com>
	<fb53a0d821374fd6bed4861884861e96@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Faivre <thomas.faivre@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:35147 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754270AbcARTp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 14:45:29 -0500
In-Reply-To: <fb53a0d821374fd6bed4861884861e96@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jan 2016 17:10:20 +0000
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> From: Thomas Faivre <thomas.faivre@6wind.com>
> 
> grff wrapper returns warnings when parsing the ip-link.8.in file.
> 
> How to reproduce:
> $ man --warnings ip-link > /dev/null
> `R' is a string (producing the registered sign), not a macro.
> [...]
> 
> Signed-off-by: Thomas Faivre <thomas.faivre@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied thanks.
