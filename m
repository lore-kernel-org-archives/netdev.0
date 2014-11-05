From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 02/20] selftests/net: move test out of Makefile into a
 shell script
Date: Wed, 05 Nov 2014 08:28:36 -0700
Message-ID: <545A4224.5030608@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com> <cover.1415117102.git.shuahkh@osg.samsung.com> <51d57725e89809806bd8af5555af341296cc4dd7.1415117102.git.shuahkh@osg.samsung.com> <20141104.145315.548353349719796428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:43569 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112AbaKEP2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 10:28:45 -0500
In-Reply-To: <20141104.145315.548353349719796428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2014 12:53 PM, David Miller wrote:
> From: Shuah Khan <shuahkh@osg.samsung.com>
> Date: Tue,  4 Nov 2014 10:10:58 -0700
> 
>> Currently bpf test run from the Makefile. Move it out of the
>> Makefile to be run from a shell script to allow the test to
>> be run as stand-alone test, in addition to allowing the test
>> run from a make target.
>>
>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 

Thanks. Queuing this patch up for 3.19-rc1.

-- Shuah

-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
