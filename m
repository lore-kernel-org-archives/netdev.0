From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] man: ip, ip-link: Fix ip option location
Date: Tue, 31 May 2016 12:54:59 -0700
Message-ID: <20160531125459.2e3f45b1@xeon-e3>
References: <1464633987-2977-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:63854 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750813AbcEaTyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 15:54:53 -0400
In-Reply-To: <1464633987-2977-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 May 2016 20:46:27 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This patch drops the redundant description of some of ip's options in
> ip-link.8's description of the 'show' subcommand, preserving the
> description of -iec (but appending it to the list in ip.8 with minor
> fixes).
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
