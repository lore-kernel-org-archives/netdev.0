From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Fri, 9 Jan 2009 10:47:11 -0000 (WET)
Message-ID: <1504.192.168.1.3.1231498031.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <200901082357.13396.denys@visp.net.lb>
    <20090109103030.GI4605@ff.dom.local>
    <200901091232.09923.denys@visp.net.lb>
    <20090109104411.GJ4605@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly01.isp.novis.pt ([195.23.133.211]:56310 "EHLO
	mailrly01.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099AbZAIKqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:46:47 -0500
In-Reply-To: <20090109104411.GJ4605@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For my case this has any matter?


> On Fri, Jan 09, 2009 at 12:32:09PM +0200, Denys Fedoryschenko wrote:
>> HZ still matter? With tickless kernel and hrtimers?
>
> Sure, "jiffies" value which depends on CONFIG_HZ is added/checked for
> in many places in networking and elsewhere.
>
> Jarek P.
>


