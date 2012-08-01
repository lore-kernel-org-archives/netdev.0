From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: iputils git tree
Date: Wed, 01 Aug 2012 13:50:15 +0900
Message-ID: <5018B587.4030705@linux-ipv6.org>
References: <201203182107.43855.vapier@gentoo.org> <5018A0A8.4000107@linux-ipv6.org> <5018AC1E.2010704@linux-ipv6.org> <201208010016.22035.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Noah Meyerhans <frodo@morgul.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:47347 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750941Ab2HAEuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 00:50:21 -0400
In-Reply-To: <201208010016.22035.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012=E5=B9=B408=E6=9C=8801=E6=97=A5 13:16), Mike Frysinger wrote:ll
> On Wednesday 01 August 2012 00:10:06 YOSHIFUJI Hideaki wrote:
>> Hello.
>>
>> (2012/08/01 12:21), YOSHIFUJI Hideaki wrote:
>>> (2012/08/01 11:46), Noah Meyerhans wrote:
>>>> On Sun, Mar 18, 2012 at 09:07:42PM -0400, Mike Frysinger wrote:
>>>>> the iputils homepage says to use:
>>>>>      git://git.linux-ipv6.org/gitroot/iputils.git
>>>>>
>>>>> but attempting to clone from that gets me connection refused.  th=
e
>>>>> gitweb is
>>>>>
>>>>> still alive though and shows recent commits:
>>>>>      http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=3Dgitroot/iput=
ils.git;a
>>>>>      =3Dsummary
>>>>>
>>>>> so where can i clone this tree ?
>>>>
>>>> Hi all. The iputils git repo still seems unavailable for cloning. =
Is
>>>> there any possibility we could get this fixed? I was able to clone=
 from
>>>> git://git.linux-ipv6.org/gitroot/iputils.git
>>>> at some point in the past, but it was more than a year ago.
>>>
>>> Sorry, I'll fix.
>>
>> DNS entry has been updated and you can reach it after a while.
>> I am sorry for any inconvenience.
>
> i can clone git://git.linux-ipv6.org/gitroot/iputils.git now, but it =
seems to
> be pointing at a different clone than is viewable from gitweb.  it's =
stuck at:
>
> commit 2384927c0ac1bb3ad21966350644d08faadb7a76
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Wed Oct 6 20:59:20 2010 +0900
>
>      iputils-s20101006

Sorry, files were out of sync.  Updated.

--yoshfuji
