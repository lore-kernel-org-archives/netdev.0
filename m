From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Fri, 9 Jan 2009 12:32:09 +0200
Message-ID: <200901091232.09923.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082357.13396.denys@visp.net.lb> <20090109103030.GI4605@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jorge Bastos <mysql.jorge@decimal.pt>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43321 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbZAIKcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:32:00 -0500
In-Reply-To: <20090109103030.GI4605@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HZ still matter? With tickless kernel and hrtimers?

On Friday 09 January 2009 12:30:30 Jarek Poplawski wrote:
> On Thu, Jan 08, 2009 at 11:57:13PM +0200, Denys Fedoryschenko wrote:
> > Can 100HZ be issue?
>
> Generally, if you need precise scheduling HZ=1000 should be used if
> higher cpu usage isn't a problem.
>
> Jarek P.


