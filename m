From: Peter Foley <pefoley2@pefoley.com>
Subject: Re: [PATCH net] ptp: restore the makefile for building the test program.
Date: Wed, 22 Oct 2014 15:43:45 -0400
Message-ID: <CAOFdcFO8ez8cGrR1=GtRUGD6mPtYxU-QMHDw8j-nn1t_=4qTsA@mail.gmail.com>
References: <edb4b32ca0326b648d905620d95297cef5ed9391.1414006463.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:58638 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465AbaJVToN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:44:13 -0400
Received: by mail-vc0-f182.google.com with SMTP id la4so2494687vcb.13
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 12:44:11 -0700 (PDT)
In-Reply-To: <edb4b32ca0326b648d905620d95297cef5ed9391.1414006463.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 3:35 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch brings back the makefile called testptp.mk which was removed
> in commit adb19fb66eee (Documentation: add makefiles for more targets).
>
> While the idea of that commit was to improve build coverage of the
> examples, the new Makefile is unable to cross compile the testptp program.
> In contrast, the deleted makefile was able to do this just fine.
>
> This patch fixes the regression by restoring the original makefile.
>
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Peter Foley <pefoley2@pefoley.com>
