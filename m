From: "Barry K. Nathan" <barryn@pobox.com>
Subject: Re: 2.6.17: networking bug??
Date: Tue, 13 Jun 2006 13:45:43 -0700
Message-ID: <986ed62e0606131345w7bdad0aap53e2edc5fea0f68f@mail.gmail.com>
References: <448EC6F3.3060002@rtr.ca> <448ECB09.3010308@rtr.ca>
	 <448ED2FC.2040704@rtr.ca> <448ED9B3.8050506@rtr.ca>
	 <448EEE9D.10105@rtr.ca> <448EF45B.2080601@rtr.ca>
	 <448EF85E.50405@psc.edu>
	 <Pine.LNX.4.64.0606131048550.5498@g5.osdl.org>
	 <448F03B3.5040501@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds@osdl.org>, "Mark Lord" <lkml@rtr.ca>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.197]:46095 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932230AbWFMUpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 16:45:44 -0400
Received: by nz-out-0102.google.com with SMTP id v1so1457634nzb
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 13:45:43 -0700 (PDT)
To: "John Heffner" <jheffner@psc.edu>
In-Reply-To: <448F03B3.5040501@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/13/06, John Heffner <jheffner@psc.edu> wrote:
> Though I haven't gotten my hands on it, I believe Windows will soon have
> this capability, too.  I'm sure Windows is big enough that whenever they
> turn this on, it will flush out all these boxes pretty quickly.  We
> could wait for them to do it first, that that's not my favored approach.

Yes, that appears to be the case with Windows Vista:
http://blogs.msdn.com/wndp/archive/2006/05/05/Winhec_blog_tcpip_2.aspx

*However*, they're also adding "black hole detection", for working
around broken boxes that drop ICMP. And that kinda makes me wonder how
long they're going to stick to their guns for enabling window scaling.
(For instance, if too many sites break, maybe they'll disable it again
with Vista Service Pack 1 or something.)
-- 
-Barry K. Nathan <barryn@pobox.com>
