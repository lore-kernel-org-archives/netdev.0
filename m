From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Scaling Max IP address limitation
Date: Sun, 24 Jun 2007 11:02:36 -0700
Message-ID: <20070624110236.fa36b2f9.akpm@linux-foundation.org>
References: <467EA7C1.4080006@rossove.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: djones@rossove.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42455 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751505AbXFXSDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 14:03:16 -0400
In-Reply-To: <467EA7C1.4080006@rossove.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Jun 2007 12:20:01 -0500 David Jones <djones@rossove.com> wrote:

> Hi,
> I am trying to add multiple IP addresses ( v6 ) to my FC7 box on eth0. 
> But I am hitting a max limit of 4000 IP address . Seems like there is a 
> limiting variable in linux kernel (which one? ) that prevents from 
> adding more IP addresses than 4096. What do I need to change in Linux 
> kernel  ( and then recompile ) to be able to add more IP addresses than 
> 4K addresses per system? ..

(cc netdev)
