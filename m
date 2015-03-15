From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH net-next 1/8] iproute2: Add a source addres length
 parameter to rt_addr_n2a
Date: Sun, 15 Mar 2015 12:33:37 -0700
Message-ID: <20150315123337.2694183a@urahara>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33525 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751249AbbCOTdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:33:37 -0400
In-Reply-To: <c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Mar 2015 18:52:09 +0000
"Eric W. Biederman" <ebiederm@xmission.com> wrote:

> 
> For some address families (like AF_PACKET) it is helpful to have the
> length when printing the address.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>  

Recent changes to utils.h make this patch no longer apply cleanly.
Please redo thanks.
