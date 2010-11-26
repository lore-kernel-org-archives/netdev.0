From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment bsockets and num_owners
Date: Thu, 25 Nov 2010 23:49:33 -0800 (PST)
Message-ID: <341722.22818.qm@web53703.mail.re2.yahoo.com>
References: <1290756031.2678.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53703.mail.re2.yahoo.com ([206.190.37.24]:38482 "HELO
	web53703.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752539Ab0KZHtf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 02:49:35 -0500
In-Reply-To: <1290756031.2678.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Fri, 26/11/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> 
> Interesting, how did you notice it is wrong ?
> 

Bumped on it while reading related code. 


      
