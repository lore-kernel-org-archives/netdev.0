From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [Bugme-new] [Bug 7817] New: commit edfe21a29b1dca9ce5a938317868066d2e21c385
 breaks IPv6 address autoconfiguration
Date: Mon, 15 Jan 2007 06:47:50 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0701150646250.4252@netcore.fi>
References: <200701131344.l0DDidDq007345@fire-2.osdl.org>
 <20070113134506.6021cf79.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:41222 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXAOErw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jan 2007 23:47:52 -0500
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.12.11.20060614/8.12.11) with ESMTP id l0F4loxP004465
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 06:47:50 +0200
To: netdev@vger.kernel.org
In-Reply-To: <20070113134506.6021cf79.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Jan 2007, Andrew Morton wrote:
>> On Sat, 13 Jan 2007 05:44:39 -0800 bugme-daemon@bugzilla.kernel.org wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=7817
>>
>>            Summary: commit edfe21a29b1dca9ce5a938317868066d2e21c385 breaks
>>                     IPv6 address autoconfiguration
>>     Kernel Version: 2.6.19.2
>>             Status: NEW
>>           Severity: high
>>              Owner: yoshfuji@linux-ipv6.org
>>          Submitter: gernoth@informatik.uni-erlangen.de
>>
>>
>> Most recent kernel where this bug did *NOT* occur: 2.6.19.1
>> Distribution: Debian Testing
>> Hardware Environment: About 100 different x86 boxes
>> Software Environment: no special software involved, just the kernel. No modules are loaded on the
>> affected machines (everything needed is built into the kernel)
>>

I got hit by this as well.  2.6.20rc4-git4 is also affected.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
