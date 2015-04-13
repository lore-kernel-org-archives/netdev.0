From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2 3/3] ipnetns: add a runtime check for
 RTM_GETNSID support
Date: Mon, 13 Apr 2015 08:53:22 -0700
Message-ID: <20150413085322.65827cb0@urahara>
References: <5527F790.4080301@6wind.com>
	<1428913385-4331-1-git-send-email-nicolas.dichtel@6wind.com>
	<f5aa0068662f470e988a01e3b92450f1@HQ1WP-EXMB12.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vadim4j@gmail.com" <vadim4j@gmail.com>,
	"jbenc@redhat.com" <jbenc@redhat.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:62855 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932097AbbDMPx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:53:29 -0400
In-Reply-To: <f5aa0068662f470e988a01e3b92450f1@HQ1WP-EXMB12.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2015 08:23:05 +0000
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> The goal of this patch is to test during the runtime if the command RTM_GETNSID
> is supported by the kernel.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied for 4.0
