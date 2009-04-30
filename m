From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH/RFC 0/2] HFSC & Stab documentation
Date: Thu, 30 Apr 2009 23:04:36 +0300
Message-ID: <200904302304.36693.denys@visp.net.lb>
References: <cover.1235685021.git.soltys@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43785 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbZD3UF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 16:05:27 -0400
In-Reply-To: <cover.1235685021.git.soltys@ziu.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any chances that this patches will go to mainstream?

On Friday 27 February 2009 01:01:30 Michal Soltys wrote:
> These patches add documentation for HFSC scheduler
> and size tables. See patch covers for detailed info.
>
> Michal Soltys (2):
>   HFSC (7) & (8) documentation + assorted changes
>   Stab documentation + assorted changes
>
>  Makefile           |    2 +
>  man/man7/tc-hfsc.7 |  525
> ++++++++++++++++++++++++++++++++++++++++++++++++++++ man/man8/tc-hfsc.8 |  
> 61 ++++++
>  man/man8/tc-stab.8 |  156 ++++++++++++++++
>  man/man8/tc.8      |    3 +
>  tc/q_hfsc.c        |    6 +-
>  tc/tc_core.c       |    4 +-
>  tc/tc_stab.c       |    9 +-
>  8 files changed, 759 insertions(+), 7 deletions(-)
>  create mode 100644 man/man7/tc-hfsc.7
>  create mode 100644 man/man8/tc-hfsc.8
>  create mode 100644 man/man8/tc-stab.8
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


