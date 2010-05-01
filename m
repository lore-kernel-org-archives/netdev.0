From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Sat, 01 May 2010 16:09:26 +0200
Message-ID: <4BDC3616.4080206@grandegger.com>
References: <20100429091936.GA6703@riccoc20.at.omicron.at> <4BDB1A51.20505@grandegger.com> <20100501140823.GA2779@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:57233 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab0EAOLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:11:19 -0400
In-Reply-To: <20100501140823.GA2779@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Fri, Apr 30, 2010 at 07:58:41PM +0200, Wolfgang Grandegger wrote:
>>>  include/linux/Kbuild             |    1 +
>>>  include/linux/ptp_clock.h        |   37 +++++
>> ptp_clock.h should probably be added to "include/linux/Kbuild".
> 
> But it already is, see the two lines above. Or did you mean something
> else?

Oops, sorry for the noise.

Wolfgang.
