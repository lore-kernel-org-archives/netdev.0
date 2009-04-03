From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [net-2.6 PATCH 0/9] Neterion: New driver: vxge: Resubmit #4
Date: Fri, 03 Apr 2009 13:21:57 -0700
Message-ID: <49D66FE5.7080602@hp.com>
References: <1238194418.5516.363.camel@flash> <1238645626.18544.209.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:31697 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbZDCUWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 16:22:01 -0400
In-Reply-To: <1238645626.18544.209.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa wrote:
> Dave,
> 
> This series of 9 patches are a resubmission of Neterion's "vxge"
> driver. We've fixed the problems observed on the sparc64, ppc64 and IA64 
> plaforms. The driver has undergone a short test cycle on these platforms
> as well as x86 and x86_64 systems.

While the horse has already left the barn, I'll go ahead and add that I've done 
some basic netperf stuff on IA64 with the card using the driver in the net-2.6 
tree and so will say:

Tested-by: Rick Jones <mr.netperf@hp.com>

rick jones
