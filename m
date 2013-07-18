From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Thu, 18 Jul 2013 10:53:53 -0700
Message-ID: <51E82BB1.7090605@hp.com>
References: <20130716025954.GC26761@windriver.com> <1374112504.7622.49.camel@envy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:16641 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759037Ab3GRRxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 13:53:55 -0400
In-Reply-To: <1374112504.7622.49.camel@envy.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2013 06:55 PM, Darren Hart wrote:
> On Mon, 2013-07-15 at 22:59 -0400, Paul Gortmaker wrote:
>
>>     IMPORTANT:  Do not send new net-next content to netdev during the
>>     period during which net-next tree is closed.
>>
>>     Shortly after the two weeks have passed, (and vX.Y-rc1 is released) the
>>     tree for net-next reopens to collect content for the next (vX.Y+1) release.
>

yesterday I tried to send an email to Jeremy Kerr asking if there was 
some way to tweak patchwork to allow DaveM a way to signal net-next 
being closed - perhaps some message at 
http://patchwork.ozlabs.org/project/netdev/list/  Baring that, I 
wondered if it would be possible to submit a dummy "[PATCH net-next] 
net-next closed until futher notice" patch,  and fake-out the date to be 
some point in the future, so it would appear at the top of the list of 
patches.

rick jones
