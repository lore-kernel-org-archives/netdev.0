From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: mark methods static and annotate for correct
 endianness
Date: Sat, 16 Oct 2010 11:55:22 -0700 (PDT)
Message-ID: <20101016.115522.112614028.davem@davemloft.net>
References: <1286958034-19372-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879Ab0JPSzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:55:00 -0400
In-Reply-To: <1286958034-19372-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 13 Oct 2010 01:20:34 -0700

> Their doesn't appear to be bugs with the endianness handling here, just get the
> annotations right to keep sparse happy.
> 
> Suppresses the following sparse warnings:
 ...
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
