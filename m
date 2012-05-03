From: =?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <darkbasic@linuxsystems.it>
Subject: Re: sky2 still badly broken
Date: Thu, 03 May 2012 11:40:10 +0200
Message-ID: <4FA2527A.6020808@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net> <4FA14EC6.6050207@linuxsystems.it> <20120502115618.04ab8ff9@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:45551 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756021Ab2ECJjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 05:39:04 -0400
In-Reply-To: <20120502115618.04ab8ff9@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 02/05/2012 20:56, Stephen Hemminger ha scritto:
> It could be that your switch doesn't do autonegotiation or flow
> control. You are getting receive fifo overflow errors.

I don't have this problem with other NICs. Also transfer rate is very=20
low (even 2 MB/s sometimes) while I get ~110MB/s with other NICs (and=20
the same switch of course).

Niccol=C3=B2
