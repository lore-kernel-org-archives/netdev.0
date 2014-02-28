From: "Andrey Mazo" <mazo@telum.ru>
Subject: Re: [PATCH 0/4] bridge-utils: build system fixes and cleanups
Date: Fri, 28 Feb 2014 22:46:47 +0400
Message-ID: <op.xbz839r7vp3tvr@hippo.telum.ru>
References: <1393239406-8504-1-git-send-email-mazo@telum.ru>
 <20140228101720.7a826230@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.telum.ru ([62.141.76.179]:53920 "EHLO mail.telum.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbaB1Sp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 13:45:28 -0500
In-Reply-To: <20140228101720.7a826230@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Feb 2014 22:17:20 +0400, Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Mon, 24 Feb 2014 14:56:42 +0400
> Andrey Mazo <mazo@telum.ru> wrote:
>
>> This short patch series implements several enhancements to the bridge-utils
>> build system.
>> The first two patches had already been sent to the bridge list [1,2]
>> but unfortunately got no response.
>> I've recently sent the whole patch series to the bridge list [3]
>> but forgot to CC netdev list.
>> I appologize if you receive multiple copies of this series.
>>
>> [1] http://lists.linuxfoundation.org/pipermail/bridge/2013-August/008535.html
>> [2] http://lists.linuxfoundation.org/pipermail/bridge/2013-August/008536.html
>> [3] http://lists.linuxfoundation.org/pipermail/bridge/2014-February/008711.html
>>
>> Andrey Mazo (4):
>>   bridge-utils: Abort compilation on error in any subdirectory
>>   bridge-utils: Removed unused variable in doc/Makefile.in
>>   bridge-utils: AC_OUTPUT should be used without arguments
>>   bridge-utils: Pretty print configure help
>>
>>  Makefile.in     |  4 ++--
>>  configure.ac    | 12 ++++++++----
>>  doc/Makefile.in |  2 --
>>  3 files changed, 10 insertions(+), 8 deletions(-)
>>
>
> Looks good, accepted.

Thank you very much!

-- 
Andrey Mazo.
