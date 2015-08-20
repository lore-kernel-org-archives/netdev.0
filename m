From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH, net-next] r8169:Avoid to use I/O Space access on new
 design and others
Date: Thu, 20 Aug 2015 06:40:23 -0700
Message-ID: <1440078023.6610.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440073712-26826-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35569 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbbHTNkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 09:40:25 -0400
Received: by pdob1 with SMTP id b1so14481805pdo.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 06:40:24 -0700 (PDT)
In-Reply-To: <1440073712-26826-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 15:28 +0300, Corcodel Marian wrote:
> Avoid to use on pci express interface I/O Space access   
>  and do not enable Bus Master is set on BIOS.   Warning: Do not apply this
>  patch must   apply previously patch  first.
> To: netdev@vger.kernel.org

It is time you carefully read Documentation/SubmittingPatches

Seriously.
