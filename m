From: =?utf-8?b?0KXQsNC90LrQuNC9INCa0L7QvdGB0YLQsNC90YLQuNC9?=
	<homecreate@list.ru>
Subject: Re: Why linux keeps connected routes when link goes down
Date: Mon, 23 Feb 2009 23:02:55 +0500
Message-ID: <200902232302.56819.homecreate@list.ru>
References: <200902190203.41497.homecreate@list.ru> <20090220.121508.252047266.davem@davemloft.net> <20090223143830.GA23244@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx33.mail.ru ([94.100.176.47]:23719 "EHLO mx33.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbZBWSDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 13:03:04 -0500
In-Reply-To: <20090223143830.GA23244@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Fortunately patching some sense into the linux kernel isn't very hard.

Can I hope that it will be done some day?

Linux is used as router in many places, such behavior is a suicide. Of course, 
one can use ifplugd (so do I), but it's a crap for network OS, don't you think 
so?

Who made linux network subsystem? Can Linus Torvalds say some words about this 
problem?

I'm not a developer, but network administrator. So I can't make a patch. I can 
only find a solution or make it. So please make my work a bit easier

--
Konstantin
E-mail homecreate@list.ru
Jabber homecreate@jabber.ru
