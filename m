From: James Chapman <jchapman@katalix.com>
Subject: Re: [v2] Re: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Tue, 10 Apr 2012 11:47:39 +0100
Message-ID: <4F840FCB.9050504@katalix.com>
References: <20120214223112.GB6806@kvack.org> <1329282410.2555.31.camel@edumazet-laptop> <4F3B6C26.4090701@katalix.com> <4F632FB6.9010206@katalix.com> <20120319032807.GD11293@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:54765 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab2DJKrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 06:47:42 -0400
In-Reply-To: <20120319032807.GD11293@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/03/12 03:28, Benjamin LaHaise wrote:
> On Fri, Mar 16, 2012 at 12:19:02PM +0000, James Chapman wrote:
>> Hi Ben,
>>
>> Do you have an updated patch to test?
> 
> Yes, here's an updated version.  

We've tested this in several L2TP environments - looks good. Will you be
submitting a version soon?

We have additional patches ready for review which add IPv6 for L2TPv3,
applying on top of your L2TPv2 patch. We also have a patch for iproute2
to add support for unmanaged L2TPv3 ethernet pseudowires over IPv6. They
can be posted when your L2TPv2 patch is submitted, or as an RFC if you
aren't ready to submit your patch yet.

James
