From: Volkan YAZICI <volkan.yazici@gmail.com>
Subject: Re: How To Temporarily Suspend Network Traffic
Date: Tue, 01 Feb 2011 20:22:20 +0200
Message-ID: <87tygn399f.fsf@alamut.ozu.edu.tr>
References: <87d3nbakwx.fsf@alamut.ozu.edu.tr> <4D4843B0.1090803@hp.com>
	<20110201094923.4fa6637f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52554 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1BATDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 14:03:38 -0500
Received: by wyb28 with SMTP id 28so7019311wyb.19
        for <netdev@vger.kernel.org>; Tue, 01 Feb 2011 11:03:37 -0800 (PST)
In-Reply-To: <20110201094923.4fa6637f@nehalam> (Stephen Hemminger's message of
	"Tue, 1 Feb 2011 09:49:23 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Feb 2011 09:49:23 -0800, Stephen Hemminger writes:
> What about using tc mired to redirect to dummy device? or use netem drop

Ohh! I have just heard about netem. I'll definitely give it a try.
Thanks!


Regards.

P.S. I will ofcourse google and read the documentation that I can find
     about these stuff. OTOH, I'd be really appreciated if you can point
     me some relevant material. Kind of material, that is, which might
     not be able to easily reachable via searching and following links.
