From: Todd Merritt <tmerritt@email.arizona.edu>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Tue, 28 Jul 2009 06:37:12 -0700
Message-ID: <4A6EFF08.2050009@email.arizona.edu>
References: <1248266678.17215.15.camel@localhost.localdomain>  <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>  <1248338779.17215.23.camel@localhost.localdomain>  <1248362493.17215.45.camel@localhost.localdomain> <1248424910.17215.54.camel@localhost.localdomain> <Pine.WNT.4.64.0907241142370.2084@ppwaskie-MOBL2.amr.corp.intel.com> <loom.20090727T214746-75@post.gmane.org> <Pine.WNT.4.64.0907271530400.5004@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gremlin.email.arizona.edu ([128.196.133.171]:11514 "EHLO
	mailgator.email.arizona.edu" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751034AbZG1O3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 10:29:44 -0400
In-Reply-To: <Pine.WNT.4.64.0907271530400.5004@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, we're running the stock kernel.  We can reliably reproduce it here.  
Please let me know if there's anything we can do to help you with 
providing a fix.

Thanks,
Todd

Waskiewicz Jr, Peter P wrote:
> On Mon, 27 Jul 2009, Todd Merritt wrote:
>
>   
>> We're getting a panic in the same function with the stable version of the ixgbe
>> driver 2.0.38.2-1 on redhat 5 kernel-2.6.18-128.1.10.el5.  Is there a dev
>> release of the driver that might have a fix in it ?
>>     
>
> Are you also running with preemption enabled?  We're having a very tough 
> time reproducing this bug in our lab, so no, we don't have any fix for it 
> yet.
>
> -PJ
>
>   

