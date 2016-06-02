From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 1/6] start gitignore files
Date: Thu, 2 Jun 2016 17:57:01 +0900
Message-ID: <574FF4DD.8030006@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <574F94B5.5040100@miraclelinux.com> <20160602044250.GN7717@vapier.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33017 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbcFBI5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 04:57:05 -0400
Received: by mail-pf0-f182.google.com with SMTP id b124so29098358pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 01:57:05 -0700 (PDT)
In-Reply-To: <20160602044250.GN7717@vapier.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> On 02 Jun 2016 11:06, YOSHIFUJI Hideaki wrote:
>> Mike Frysinger wrote:
>>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>>> ---
>>>  .gitignore     | 22 ++++++++++++++++++++++
>>>  doc/.gitignore |  2 ++
>>>  2 files changed, 24 insertions(+)
>>>  create mode 100644 .gitignore
>>>  create mode 100644 doc/.gitignore
>>>
>>
>> files under ninfod/ as well, maybe?
> 
> perhaps ... i've never seen this dir before.  it has generated files
> committed to the git repo though which kind on conflicts with using
> gitignore.
> 
> maybe merge this and then wait for someone who actually builds/tests
> ninfod to submit an update ?
> -mike
> 

Okay, applied.  Thanks.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
