From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Tue, 13 May 2008 11:20:07 +0100
Message-ID: <48296B57.50006@andyfurniss.entadsl.com>
References: <4815BCDF.6070704@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi> <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi> <481986FD.8070108@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi> <48199342.9010406@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805021342480.30402@wrl-59.cs.helsinki.fi> <481C54AF.1050109@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805121349400.1888@wrl-59.cs.helsinki.fi>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?77+9?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:58142 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752199AbYEMKUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 06:20:08 -0400
In-Reply-To: <Pine.LNX.4.64.0805121349400.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BF=BD wrote:
> On Sat, 3 May 2008, Andy Furniss wrote:
>=20
>> Ilpo J=EF=BF=BDrvinen wrote:
>>
>>> Since I've not yet found any other path that could lead to it excep=
t the
>>> yesterday's false-positive, getting the write queue state more accu=
rately
>>> captured by the debug patch on the very first occassion might help.=
 Here's
>>> less spammy version of the debug patch (I added one printout as wel=
l to get
>>> more usefulness to transitional state reported).
>>>
>> OK, increased CONFIG_LOG_BUF_SHIFT from 14 to 18 and reversed old / =
applied
>> new patch.
>=20
> Any luck so far?
>=20

No, nothing yet :-(

