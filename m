From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [ANNOUNCE] iproute2 v2.6.29
Date: Thu, 26 Mar 2009 15:31:23 +0530
Message-ID: <49CB5273.3000400@linux.vnet.ibm.com>
References: <20090324153427.3ff0dfdb@nehalam> <49CA5C82.3000706@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:56752 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbZCZKB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 06:01:27 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2QA1NRA031383
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 15:31:23 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2Q9vpKD3678398
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 15:27:51 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2QA1Nbf011599
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 15:31:23 +0530
In-Reply-To: <49CA5C82.3000706@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> Stephen Hemminger wrote:
>   
>> Trying to stay on top of things (for a change).
>>
>> New version of iproute2 utilities that includes bug fixes and
>> support for all the new features in kernel 2.6.29.
>>
>>   http://devresources.linux-foundation.org/dev/iproute2/download/iproute2-2.6.29.tar.bz2
>>
>> Denys Fedoryschenko (1):
>>       Fix memory leak in local options
>>
>> Jamal Hadi Salim (1):
>>       Breakage noticed when debian upgraded to xtables (iptables > 1.4.1)
>>
>> Patrick McHardy (1):
>>       iproute: add DRR support
>>
>> Stephen Hemminger (7):
>>       fix uninitialized memory in tc_skbedit
>>       Add missing limits.h
>>       Add DHCP as routing protocol
>>       Add support for IFALIAS
>>       Handle default hoplimit
>>       Use sanatized headers from 2.6.29
>>       Update snapshot
>>     
>
>   
Hi Stephen,
         
                      I noticed that you have missed out on 2 patches i 
submitted. Incase it slipped through can you please look into it?

http://patchwork.ozlabs.org/patch/24337/
http://patchwork.ozlabs.org/patch/24338/


Regards,
Varun
