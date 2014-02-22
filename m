From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: "ip route show" not in usage() for ip
Date: Sat, 22 Feb 2014 12:58:19 +0100
Message-ID: <20140222115819.GB6598@order.stressinduktion.org>
References: <53073E48.7060303@dergleichrichter.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Justus Seifert <justus.seifert@dergleichrichter.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45436 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbaBVL6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 06:58:20 -0500
Content-Disposition: inline
In-Reply-To: <53073E48.7060303@dergleichrichter.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Feb 21, 2014 at 12:53:44PM +0100, Justus Seifert wrote:
> i was looking at the synopsis of ip and noticed that the command "ip
> route show" is not mentioned in the usage summary of ip.  is this
> intended?  is this operand deprecated?

"show" is just an alias for "list", which is shown in the synopsis.

Greetings,

  Hannes
