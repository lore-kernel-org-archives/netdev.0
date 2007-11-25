From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: forcedeth ethernet driver & Low power state
Date: Sat, 24 Nov 2007 22:39:28 -0800
Message-ID: <20071124223928.796a4c6e.akpm@linux-foundation.org>
References: <c22ebab10711241852v687b384fpd638ff565756232a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Jeroen <j.geusebroek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54467 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753989AbXKYGjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 01:39:48 -0500
In-Reply-To: <c22ebab10711241852v687b384fpd638ff565756232a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 25 Nov 2007 03:52:33 +0100 Jeroen <j.geusebroek@gmail.com> wrote:

> Hi,
> 
> I'm migrating my server from windows 2003 server to Ubuntu, but I am
> stumbling over the "Low Power State Link Speed" option for my NIC
> (forcedeth)
> 
> I need to disable this option in my windows driver otherwise the trough pout is
> horrible because the link fluctuates constantly from 100/1000.
> 
> Anyway, my question is where and how can I turn off this feature for the
> forcedeth driver? I've looked in the source and as far as I can tell there is no
> bootoption for this. There are some references noted in the code, but AFAIK
> no setting.
> 
> Any ideas? Thanks in advance!
> 

(cc's added)
