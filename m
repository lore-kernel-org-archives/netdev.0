From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] [3.20] NFC update
Date: Wed, 28 Jan 2015 22:50:19 -0800 (PST)
Message-ID: <20150128.225019.1581863333410734561.davem@davemloft.net>
References: <20150129005216.GA1137@ribalta.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269AbbA2GuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 01:50:20 -0500
In-Reply-To: <20150129005216.GA1137@ribalta.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <sameo@linux.intel.com>
Date: Thu, 29 Jan 2015 01:52:16 +0100

> This is the first NFC pull request for 3.20.
> 
> With this one we have:
> 
> - Secure element support for the ST Micro st21nfca driver. This depends
>   on a few HCI internal changes in order for example to support more
>   than one secure element per controller.
> 
> - ACPI support for NXP's pn544 HCI driver. This controller is found on
>   many x86 SoCs and is typically enumerated on the ACPI bus there.
> 
> - A few st21nfca and st21nfcb fixes. Since they're not critical fixes,
>   I assumed it's too late for a 3.19 inclusion. Please let me know if
>   you'd prefer to see them going through a net pull request instead.

Applied, thanks Samuel.
