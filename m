From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] misc/Makefile: use PKG_CONFIG
Date: Mon, 23 Nov 2015 15:26:27 -0800
Message-ID: <20151123152627.63e3935e@xeon-e3>
References: <1447769280-11421-1-git-send-email-aaro.koskinen@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:49263 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753349AbbKWX0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:26:24 -0500
In-Reply-To: <1447769280-11421-1-git-send-email-aaro.koskinen@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2015 16:08:00 +0200
Aaro Koskinen <aaro.koskinen@nokia.com> wrote:

> Use PKG_CONFIG from Config - it works better when cross-compiling.
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>

Looks good, applied.
