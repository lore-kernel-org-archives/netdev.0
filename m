From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: s2io: packet reordering with 2.6.25.4
Date: Thu, 26 Jun 2008 10:28:49 +0200
Message-ID: <48635341.8010609@gmail.com>
References: <4862DEA4.8020305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
To: Tom Quetchenbach <virtualphtn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:42909 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbYFZI3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 04:29:18 -0400
Received: by nf-out-0910.google.com with SMTP id d3so225007nfc.21
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 01:29:17 -0700 (PDT)
In-Reply-To: <4862DEA4.8020305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Quetchenbach wrote, On 06/26/2008 02:11 AM:

> We've been encountering some packet reordering with our Neterion 10
> Gigabit Ethernet-SR cards using the s2io driver in linux 2.6.25.4.

...

> Thanks, and let me know if there's anything I can do to help debug,

Out of curiosity: is there affinity set for eths' irqs or they are
balanced between cpus? (/proc/interrupts?)

Regards,
Jarek P.


