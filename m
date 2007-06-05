From: Paolo Galtieri <pgaltieri@mvista.com>
Subject: Re: What test suite exists for SCTP
Date: Tue, 05 Jun 2007 13:46:56 -0700
Message-ID: <4665CBC0.7030809@mvista.com>
References: <4665C85C.5030803@mvista.com> <4665C9C8.6070504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Net Dev <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.mvista.com ([63.81.120.158]:23630 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1764248AbXFEUry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 16:47:54 -0400
In-Reply-To: <4665C9C8.6070504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> Paolo Galtieri wrote:
>   
>> Vlad,
>>  what test suite exists for SCTP?  The lksctp-tools code hasn't been
>> updated since Feb of 2006, and I was wondering whether this version is
>> still the most useful.
>>
>> Thanks
>>     
>
> Hi Paolo
>
> I have a lksctp-tools tree on git.kernel.org that's up to date.  We'll need
> to release new tools when 2.6.22 ships.
>
> What kind of test suite are you looking for?  There is also a conformance test
> suite at http://sctp.fh-muenster.de/sctp-testtool.html, but I haven't played
> with it yet.
>
> I also have some home-grown tools that I really need to find time to clean-up and
> publish.
>
> -vlad
>
>   
Vlad,
  I'm looking for something that exercises the SCTP stack.   Something 
that can be run against different kernel versions for comparing features 
and regression testing.

Thanks
Paolo
