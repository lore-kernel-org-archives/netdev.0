From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Thu, 8 Jan 2009 00:36:39 +0200
Message-ID: <200901080036.39519.denys@visp.net.lb>
References: <200901080002.37223.denys@visp.net.lb> <008201c97115$091b5d50$1b5217f0$@jorge@decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jorge Bastos" <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48435 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762372AbZAGWgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 17:36:33 -0500
In-Reply-To: <008201c97115$091b5d50$1b5217f0$@jorge@decimal.pt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, but byte couting on HFSC works fine.

On Thursday 08 January 2009 00:12:30 Jorge Bastos wrote:
> I have a similar problem with CBQ that I've been reporting, that may be
> related to byte counting also.
> It just happens when I use a 1000Mbit NIC.
> I've reported it to netfilter@ and created a but report here.
> When I insert the old 100Mbit card, it works OK.
>
> http://bugzilla.kernel.org/show_bug.cgi?id=12364
>
