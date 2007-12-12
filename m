From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: Remove FASTCALL macro
Date: Wed, 12 Dec 2007 10:47:07 -0800 (PST)
Message-ID: <20071212.104707.125945677.davem@davemloft.net>
References: <1197446943.5745.9.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, linux-kernel@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54311
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755275AbXLLSrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:47:08 -0500
In-Reply-To: <1197446943.5745.9.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 12 Dec 2007 00:09:03 -0800

> X86_32 was the last user of the FASTCALL macro, now that it
> uses regparm(3) by default, this macro expands to nothing.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied to net-2.6.25, thanks.
