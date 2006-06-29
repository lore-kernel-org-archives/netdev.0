From: James Morris <jmorris@namei.org>
Subject: Re: Netchannels: progress report.
Date: Thu, 29 Jun 2006 13:19:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606291318420.24645@d.namei>
References: <20060608171555.GA10273@2ka.mipt.ru> <20060613173321.GA648@2ka.mipt.ru>
 <20060629093801.GA6049@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:21987 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751074AbWF2RTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 13:19:31 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060629093801.GA6049@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Jun 2006, Evgeniy Polyakov wrote:

> +#define __NR_netchannel_control	279
> +__SYSCALL(__NR_vmsplice, sys_netchannel_control)

This looks wrong.



-- 
James Morris
<jmorris@namei.org>
