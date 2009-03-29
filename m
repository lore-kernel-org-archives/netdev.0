From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bnx2, 2.6.29, smp_affinity strangeness
Date: Sun, 29 Mar 2009 04:27:48 +0200
Message-ID: <200903290527.49029.denys@visp.net.lb>
References: <200903290447.58338.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35531 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348AbZC2C1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:27:47 -0400
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 961991A4B9E
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 05:27:40 +0300 (EEST)
In-Reply-To: <200903290447.58338.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgot to tell
kernel 2.6.29 x86_64
userspace is 32-bit

I test also 32-bit kernel/32-bit userspace - same result.

On Sunday 29 March 2009 04:47:58 Denys Fedoryschenko wrote:
> While running bnx2 tried to assign affinity to network card and ... failed.
