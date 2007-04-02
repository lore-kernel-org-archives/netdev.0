From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PROBLEM: sky2 hangs
Date: Mon, 2 Apr 2007 12:41:10 -0700
Message-ID: <20070402124110.1c5f98d4@oldman>
References: <20070402181228.198B54AC19@dcn.infos.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Peter Trifonov" <petert@dcn.infos.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41756 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965757AbXDBTls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 15:41:48 -0400
In-Reply-To: <20070402181228.198B54AC19@dcn.infos.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Apr 2007 22:12:27 +0400
"Peter Trifonov" <petert@dcn.infos.ru> wrote:

> Hello,
> 
> I have got a PC based on Gigabyte GA-965P-S3 motherboard with an integrated
> Marvell Yukon 88E8056 PCI-E gigabit ethernet controller. 
> 
> I am using OpenSuSe Linux 10.2 x64/SMP  with 2.6.18.2-34-default kernel.

There have been several updates since 2.6.18. Please try and reproduce with
2.6.20 or later kernel. Or contact the vendor to update their kernel.
