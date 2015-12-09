From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] mpls_iptunnel: add static qualifier to mpls_output
Date: Wed, 9 Dec 2015 15:00:38 +0000
Message-ID: <56684216.4030808@brocade.com>
References: <1449673001-27596-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41265 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbbLIPAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 10:00:50 -0500
In-Reply-To: <1449673001-27596-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/15 14:56, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This gets rid of the following compile warn:
> net/mpls/mpls_iptunnel.c:40:5: warning: no previous prototype for
> mpls_output [-Wmissing-prototypes]
>

Acked-by: Robert Shearman <rshearma@brocade.com>

> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
