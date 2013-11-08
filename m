From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 08 Nov 2013 15:57:58 -0800
Message-ID: <527D7A86.5020603@hp.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com> <527C3942.509@hp.com> <1383876294.9412.136.camel@edumazet-glaptop2.roam.corp.google.com> <527D7320.4050008@hp.com> <1383954154.16391.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:10320 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757639Ab3KHX57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 18:57:59 -0500
In-Reply-To: <1383954154.16391.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2013 03:42 PM, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 15:26 -0800, Rick Jones wrote:
>> On 11/07/2013 06:04 PM, Eric Dumazet wrote:
>>>
>>> It seems you do request randomization, but you do not want it for
>>> applications written by innocent people...
>>
>> That bind() call is not there to request randomization of the TCP source
>> port.
>
> I was actually doing some kind of humor, I should have added a ;)

Sorry - been watching one of my kids most of the day, my humor/snark 
detectors were offline :)

rick
