From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] vti: remove duplicated code to fix a memory leak
Date: Sat, 29 Jun 2013 14:20:19 +0800
Message-ID: <1372486819.29178.7.camel@cr0>
References: <1372482057-12412-1-git-send-email-amwang@redhat.com>
	 <20130628221849.16c7ca0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64351 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab3F2GUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 02:20:30 -0400
In-Reply-To: <20130628221849.16c7ca0e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 22:18 -0700, Stephen Hemminger wrote:
> 
> The fix looks correct, looks like an oversight when the generic tunnel infratructure
> was added.

Yeah, I am trying to switch vti tunnel using generic tunnel code.

Thanks!
