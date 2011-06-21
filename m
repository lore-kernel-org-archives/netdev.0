From: Joyce Yu - System Software <joyce.yu@oracle.com>
Subject: Re: Steps to integrate new 40G Network driver to the kernel tree
Date: Tue, 21 Jun 2011 16:53:21 -0700
Message-ID: <4E012EF1.3050005@oracle.com>
References: <4DA8D9F6.2070908@oracle.com> <20110415175429.5e91fb59@nehalam> <4E012D80.4090907@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58266 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756933Ab1FUXwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 19:52:51 -0400
In-Reply-To: <4E012D80.4090907@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since it is a new driver, shall I follow the "Submitting Drivers for the 
Linux Kernel" Doc? The driver is ready and passed all our QA cycles. I  
have three source base, one is for 2.6.16 and 2.6.18 (for RHL 5.X and 
SLES 10 SP3) , one is for 2.6.32 (For RHL 6.X, SLES11SP1), one for 
2.6.27 (For SLES11). Can it be integrated to the 2.6.18 and 2.6.32 tree? 
or it has to be in the latest 2.6.39 or later?

Thanks,
Joyce

