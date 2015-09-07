From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] ip link/addr show: add empty line between interfaces
Date: Mon, 7 Sep 2015 17:54:11 +0200
Message-ID: <20150907175411.491f9c96@griffin>
References: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net>
	<20150907144609.3ec9f4d0@griffin>
	<1441639971-sup-8473@zero>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Kaiser <felix.kaiser@fxkr.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbbIGPyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 11:54:15 -0400
In-Reply-To: <1441639971-sup-8473@zero>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Sep 2015 17:38:48 +0200, Felix Kaiser wrote:
> My opinion is that if someone parses that, they deserve the opportunity
> to fix their code. At the very least they could have used -oneline!

No doubt. I also don't like scripts that parse the default "ip a"
output.

I just pointed out that there are different opinions and that it can
have some consequences. Personally, I have no strong feeling against
nor for the patch. It's up to Stephen to decide.

> I've met users who use a shell alias to hack newlines in

Which is not a bad solution, actually.

 Jiri

-- 
Jiri Benc
