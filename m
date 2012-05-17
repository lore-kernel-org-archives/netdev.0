From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [net-next 3/4] e1000: look in the page and not in skb->data for
 the last byte
Date: Thu, 17 May 2012 13:56:50 +0200
Message-ID: <4FB4E782.3070502@linutronix.de>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1337254070-32500-4-git-send-email-jeffrey.t.kirsher@intel.com>  <4FB4E34F.2050004@linutronix.de> <1337255417.2714.49.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44105 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab2EQL4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 07:56:55 -0400
In-Reply-To: <1337255417.2714.49.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2012 01:50 PM, Jeff Kirsher wrote:
>
> Your correct, I apologize.  This was my fault, I applied your v1 of the
> patch and then realized there was a v2.
>
> I will re-send the series with the correct patch.

Okay. I haven't seen [0] in the series. Did you merge it somewhere?

[0] http://thread.gmane.org/gmane.linux.drivers.e1000.devel/10019

Sebastian
