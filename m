From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] route: Fix printing of locked entries
Date: Thu, 17 Dec 2015 17:15:05 -0800
Message-ID: <20151217171505.33ef2cc0@xeon-e3>
References: <1449925788-30736-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55728 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965035AbbLRBPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 20:15:05 -0500
In-Reply-To: <1449925788-30736-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Dec 2015 14:09:48 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Commit 0f7543322c5fd ("route: ignore RTAX_HOPLIMIT of value -1")
> accidentally reordered fprintf statements. This patch restores the
> original ordering.
> 
> Fixes: 0f7543322c5fd ("route: ignore RTAX_HOPLIMIT of value -1")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
