From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 10:48:28 +0100
Message-ID: <20061110094828.GF8693@postel.suug.ch>
References: <45541757.90800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43233 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1946221AbWKJJsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 04:48:07 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <45541757.90800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul Moore <paul.moore@hp.com> 2006-11-10 01:08

Excellent!

>    - u32 snd_pid
> 
>      This is the PID of the client which issued the request.

In order to avoid confusion it might be better to call it
"netlink PID" as it is not equal to the process ID.
