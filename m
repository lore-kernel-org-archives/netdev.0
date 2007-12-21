From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] Module for ip utility to support veth device
Date: Fri, 21 Dec 2007 09:38:51 -0800
Message-ID: <20071221093851.5483c846@deepthought>
References: <200712181515.38565.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51412 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752681AbXLURjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 12:39:55 -0500
In-Reply-To: <200712181515.38565.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Dec 2007 15:15:38 +0300
Vitaliy Gusev <vgusev@openvz.org> wrote:

> 
> module link_veth
> 
> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> 
> ---
> 

Applied both patches, and moved veth.h from ip/veth.h to include/net/veth.h
so that the header file will be correctly updated if ABI changes.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
