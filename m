From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 11147] New: tg3 + jumbo frames +
 scatter-gather == inoperative NIC
Date: Tue, 22 Jul 2008 23:25:42 -0700
Message-ID: <C27F8246C663564A84BB7AB34397724201E1494B6D@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <cccedfc60807221838h442e3b8ah8022c07a685ead34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"jnelson-kernel-bugzilla@jamponi.net"
	<jnelson-kernel-bugzilla@jamponi.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "'Jon Nelson'" <jnelson@jamponi.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4781 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbYGWGZx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 02:25:53 -0400
In-Reply-To: <cccedfc60807221838h442e3b8ah8022c07a685ead34@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon Nelson wrote:

> What other information can I provide?
> This is 100% reproducible.
>

Please provide lspci output and tg3 signon output so that
we know what device is failing.

