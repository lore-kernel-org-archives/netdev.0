From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Fri, 24 Apr 2009 17:55:08 +0300
Message-ID: <200904241755.09198.denys@visp.net.lb>
References: <20090423084323.GA5696@ff.dom.local> <beb91d720904231632m2a66768dy95f1df1491d97f5b@mail.gmail.com> <49F1D16A.8050003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Salatiel Filho <salatiel.filho@gmail.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:58806 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025AbZDXOzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 10:55:39 -0400
In-Reply-To: <49F1D16A.8050003@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 24 April 2009 17:49:14 Patrick McHardy wrote:
>
> There is DRR since a couple of versions. Combined with the
> flow classifier, it should provide the same functionality
> as ESFQ.
I think it is even better, as soon as you understand it, it is very intuitive 
to understand and transparent, how it works.
