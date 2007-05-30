From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 17:57:20 +0100
Message-ID: <465DACF0.5080207@andyfurniss.entadsl.com>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain> <465D5D7A.8090200@andyfurniss.entadsl.com> <465D98F8.9000102@trash.net>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:42678 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753050AbXE3Q5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 12:57:06 -0400
In-Reply-To: <465D98F8.9000102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
  My classifier uses jhash,

Ahh that's OK - I thought it still used the old sfq hash, which collided 
alot with a low number of consecutive addresses.

Andy.
