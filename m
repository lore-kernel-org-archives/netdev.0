From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!     2.6.28
Date: Thu, 8 Jan 2009 23:57:13 +0200
Message-ID: <200901082357.13396.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082041.58597.denys@visp.net.lb> <1059.87.196.62.168.1231451164.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jorge Bastos" <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41747 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbZAHV5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:57:06 -0500
In-Reply-To: <1059.87.196.62.168.1231451164.squirrel@webmail.decimal.pt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can 100HZ be issue?
I have hrtimers, tsc now. Tried to change to HPET, nothing changes.


On Thursday 08 January 2009 23:46:04 Jorge Bastos wrote:
> Well... i'm out of ideias.
> CBQ seems to be working OK without the parameters disables that Jarek told
> me to disable.
>
> What can you say about this Jarek?
>
> > I check, also HFSC not keeping bandwidth accurate.
> > Seems i am totally lost, what to do.
> > Any ideas what i can try?


