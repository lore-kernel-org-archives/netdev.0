From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Linux 2.6 HTB does only work with existing connections
Date: 22 Feb 2007 14:45:01 +0100
Message-ID: <p73ps82cnmq.fsf@bingen.suse.de>
References: <01df01c75629$5c621c50$152654f0$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: "Hua Zhong" <hzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44734 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945999AbXBVMpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 07:45:07 -0500
In-Reply-To: <01df01c75629$5c621c50$152654f0$@com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Hua Zhong" <hzhong@gmail.com> writes:

> Just add more info: this machine has TOE. And if that's turned off,
> everything seems to work fine.
> 
> Does it mean that traffic control doesn't play well with TOE? Or there are
> some tricks to make them work together?

Congratulations. You discovered one of the many reasons why TOE is a 
bad idea.

-Andi
