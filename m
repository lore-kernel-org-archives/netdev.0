From: Andi Kleen <andi@firstfloor.org>
Subject: Re: PROBLEM: tg3 spitting out uninitialized memory
Date: 12 Apr 2007 16:50:03 +0200
Message-ID: <p73tzvl7ilg.fsf@bingen.suse.de>
References: <461D57E9.3000300@jwebb.sygneca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jamie webb <j@jwebb.sygneca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:48316 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753831AbXDLNvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 09:51:51 -0400
In-Reply-To: <461D57E9.3000300@jwebb.sygneca.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamie webb <j@jwebb.sygneca.com> writes:

> Hi there
> 
> I have a Dell PE860 with built-in BCM5721, which is reported as
> working fine with the tg3 driver, however I have been getting sporadic
> data corruption, mostly evident as SSH MAC errors.

FWIW i also saw this (data corruption with tg3) occasionally,
but never repeatable or with a packet dump.

-Andi
