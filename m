From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: reduce the lines of code
Date: Fri, 19 Nov 2010 07:35:40 +0100
Message-ID: <b2c34db84e88366e465af590900ae3db@localhost>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:47184 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750766Ab0KSGfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 01:35:42 -0500
In-Reply-To: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 19 Nov 2010 10:04:44 +0800, Changli Gao <xiaosuo@gmail.com> wrote:

> Use macros to reduce the regularity lines.



This is complete awkward and does not fix anything - on the contrary it

makes it harder to understand the code and no advantage is achieved.



Hagen
